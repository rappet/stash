extern crate core;

mod audio_io;
mod window;

use crate::audio_io::AudioIo;
use crate::window::WindowFunction;
use anyhow::Result;
use minifb::{Key, Window, WindowOptions};
use palette::{FromColor, LinSrgb, OklabHue, Oklch, Pixel, Srgb};
use rustfft::num_complex::{Complex, ComplexFloat};
use rustfft::FftPlanner;
use std::collections::VecDeque;
use std::iter::repeat;
use std::sync::mpsc;
use std::sync::mpsc::sync_channel;
use std::thread;
use std::time::Duration;

const SAMPLE_RATE: u32 = 48000;

const WIDTH: usize = 800;
const HEIGT: usize = 800;

fn main() -> Result<()> {
    let mut buffer: Vec<u32> = vec![0; WIDTH * HEIGT];

    let mut window = Window::new("FFT view", WIDTH, HEIGT, WindowOptions::default()).unwrap();
    window.limit_update_rate(Some(Duration::from_millis(1000 / 60)));

    let (encoder_sender, audio_receiver) = mpsc::sync_channel(100000);
    let (audio_sender, encoder_receiver) = mpsc::sync_channel(100000);
    //for _ in 0..50000 {
    //    encoder_sender.send(0);
    //}

    let _audio_io = AudioIo::start(
        move |buf| {
            for sample in buf.iter_mut() {
                if let Ok(channel_sample) = audio_receiver.try_recv() {
                    *sample = channel_sample;
                } else {
                    //eprintln!("skip");
                    break;
                }
            }
        },
        move |buf| {
            for sample in buf {
                let _ = audio_sender.send(*sample);
            }
        },
    )?;

    //let frames_per_sec = SAMPLE_RATE as f32 / c2.samples_per_frame() as f32;
    //println!(
    //    "Initialized codec: {}bit/s, {}ms/frame, {} byte/frame, {frames_per_sec} frames/sec",
    //    c2.bits_per_frame() as f32 * frames_per_sec,
    //    1000.0 / frames_per_sec as f32,
    //    (c2.bits_per_frame() + 7) / 8,
    //);

    /*loop {
        //encoder_sender.send(encoder_receiver.recv().unwrap());
        let input_samples: Vec<_> = repeat(())
            .take(c2.samples_per_frame())
            .map(|_| encoder_receiver.recv().unwrap())
            .collect();
        let mut packed = vec![0u8; (c2.bits_per_frame() + 7) / 8];
        c2.encode(&mut packed, &input_samples);

        let mut output_samples = vec![0i16; c2.samples_per_frame()];
        c2.decode(&mut output_samples, &packed);
        for sample in output_samples {
            let _ = encoder_sender.send(sample);
        }
    }*/

    let samples_per_frame = SAMPLE_RATE as usize / 100;
    println!("{samples_per_frame}");

    let fft = FftPlanner::<f32>::new().plan_fft_forward(samples_per_frame);

    let (fft_sender, fft_receiver) = sync_channel(1000);

    thread::spawn(move || {
        let mut input_samples = VecDeque::with_capacity(samples_per_frame * 10);

        let mut frame_id = 0u64;

        let window = WindowFunction::new_hamming(samples_per_frame);

        loop {
            for _ in 0..samples_per_frame / 4 {
                let _ = input_samples.pop_front();
            }

            while input_samples.len() < samples_per_frame {
                input_samples.push_back(encoder_receiver.recv().unwrap());
            }

            frame_id += 1;

            let float_samples: Vec<_> = input_samples
                .iter()
                .map(|s| *s as f32 / i16::MAX as f32)
                .collect();
            let mut hanning_samples = float_samples.clone();
            window.apply(&mut hanning_samples);

            let mut frequencies: Vec<_> = hanning_samples
                .iter()
                .map(|v| Complex::new(*v, 0.0))
                .collect();
            fft.process(&mut frequencies);
            let mut abs_frequencies: Vec<_> = frequencies
                .iter()
                .take(samples_per_frame / 2)
                .map(|c| c.abs())
                .enumerate()
                .map(|(f, e)| (f * 100, e))
                .collect();
            abs_frequencies.sort_by_key(|(_, v)| (*v * -100000.0) as i64);

            fft_sender
                .send(
                    frequencies
                        .iter()
                        .take(samples_per_frame / 2)
                        .map(|e| e.abs())
                        .collect::<Vec<_>>(),
                )
                .unwrap();

            //println!("{energy}");
        }
    });

    let (band_sender, band_recv) = sync_channel(1000);

    thread::spawn(move || {
        let mut buffer = VecDeque::with_capacity(1000);
        loop {
            while buffer.len() < 128 {
                buffer.push_back(band_recv.recv().unwrap());
            }

            analyze(buffer.make_contiguous());

            for _ in 0..4 {
                buffer.pop_front();
            }
        }
    });

    let mut last_ffts = VecDeque::with_capacity(HEIGT);

    while window.is_open() && !window.is_key_down(Key::Escape) {
        while let Ok(fft) = fft_receiver.try_recv() {
            while last_ffts.len() >= HEIGT {
                last_ffts.pop_front();
            }
            last_ffts.push_back(fft);
        }

        for (line, fft) in buffer.chunks_mut(WIDTH).zip(last_ffts.iter()) {
            let mut band = vec![0.0; 8];
            for i in 179..196 {
                if i % 2 == 0 {
                    band[(i - 179) / 2] += fft[i];
                    band[(i - 179) / 2] += fft[i + 16];
                }
            }
            let mut band_slice = [0f32; 8];
            band_slice.copy_from_slice(&band);
            band_sender.send(band_slice).unwrap();

            for (pixel, &value) in line
                .iter_mut()
                .zip(fft.iter().flat_map(|v| repeat(v).take(3)))
            {
                let l = f32::log10(value);

                let hue = OklabHue::from_degrees(90.0 * -l + 270.0);
                let lin_srgb: LinSrgb = LinSrgb::from_color(Oklch::new(0.7, 0.3, hue));
                let srgb = Srgb::from_linear(lin_srgb);

                let rgb: [u8; 3] = srgb.into_format().into_raw();

                *pixel =
                    0xFF000000 + ((rgb[2] as u32) << 16) + ((rgb[1] as u32) << 8) + (rgb[0] as u32);

                /*let d = (((l + 100.0) % 1.0) * 255.) as u32;
                *pixel = if l > 1.0 {
                    0xffff0000 + d << 8 + d
                } else if l > 0.0 {
                    0xffffff00 - (d << 8)
                } else if l > -1.0 {
                    0xff00ff00 + d << 16
                } else if l > -2.0 {
                    0xff00ff00 + (255 - d)
                } else if l > -3.0 {
                    0xff0000ff + (d << 8)
                } else if l > -4.0 {
                    0xff000000 + d
                } else {
                    0xff000000
                }*/
            }
        }

        window.update_with_buffer(&buffer, WIDTH, HEIGT).unwrap();
    }

    Ok(())
}

fn analyze(buffer: &[[f32; 8]]) {
    let mut outputs = Vec::new();
    for i in 0..4 {
        let sampled: Vec<_> = buffer.iter().skip(i).step_by(4).copied().collect();
        if let Some(s) = analyze_single(sampled.as_slice()) {
            outputs.push(s);
        }
    }
    if !outputs.is_empty() {
        println!("{}", outputs.join("; "))
    }
}

const CARRIERS: usize = 8;
fn analyze_single(buffer: &[[f32; CARRIERS]]) -> Option<String> {
    let mut averages = buffer.iter().copied().fold([0f32; CARRIERS], |mut acc, v| {
        acc.iter_mut().zip(v.iter()).for_each(|(acc, v)| *acc += *v);
        acc
    });
    averages.iter_mut().for_each(|v| *v /= buffer.len() as f32);

    let bytes: Vec<_> = buffer
        .iter()
        .cloned()
        .map(|symbol| {
            let mut bits = [false; CARRIERS];
            symbol
                .into_iter()
                .zip(bits.iter_mut())
                .zip(averages.iter())
                .for_each(|((s, bit), average)| *bit = s > *average);
            let mut v = 0u8;
            for (i, bit) in bits.into_iter().enumerate() {
                if bit {
                    v += 1 << i;
                }
            }
            v
        })
        .collect();
    if bytes.starts_with(&[
        0, 255, 0, 255, 0b10101010, 0b01010101, 0b10101010, 0b01010101,
    ]) {
        let mut sub_bytes = &bytes[8..];
        let length = sub_bytes.iter().position(|v| *v == 0).unwrap_or(0);
        sub_bytes = &sub_bytes[0..length];
        if sub_bytes.len() > 0 {
            let message = String::from_utf8_lossy(sub_bytes);
            Some(message.to_string())
        } else {
            None
        }
    } else {
        None
    }
}
