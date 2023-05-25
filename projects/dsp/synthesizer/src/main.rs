#![deny(clippy::all)]
#![warn(clippy::pedantic)]
#![warn(clippy::nursery)]
#![deny(clippy::integer_arithmetic)]
#![deny(clippy::as_conversions)]

extern crate alloc;

use audio_output::AudioOutput;
use dsp_lib::streaming::{ConstSampleSource, Mixer, Multiplier, SampleSource};
use fixed::types::I16F16;

use std::{collections::VecDeque, sync::Arc, sync::Mutex, usize};

use minifb::{Key, Window, WindowOptions};
use source::{AdsrEnvelope, AdsrParameter, AtomicSamples, ValueControlledOszilator};

use crate::display::{draw, Screen};
use crate::parameter::ControlVoltage;
use crate::source::SinWave;

mod audio_output;
mod display;
mod parameter;
mod source;

const SAMPLE_RATE: u32 = 44_100;

fn key_to_tone(key: Key) -> Option<f32> {
    match key {
        Key::A => Some(3. / 12.),
        Key::W => Some(4. / 12.),
        Key::S => Some(5. / 12.),
        Key::E => Some(6. / 12.),
        Key::D => Some(7. / 12.),
        Key::F => Some(8. / 12.),
        Key::T => Some(9. / 12.),
        Key::G => Some(10. / 12.),
        Key::Y => Some(11. / 12.),
        Key::H => Some(12. / 12.),
        Key::U => Some(13. / 12.),
        Key::J => Some(14. / 12.),
        Key::K => Some(15. / 12.),
        Key::O => Some(16. / 12.),
        Key::L => Some(17. / 12.),
        Key::P => Some(18. / 12.),
        _ => None,
    }
}

fn main() {
    #[allow(clippy::as_conversions, clippy::cast_precision_loss)]
    let sample_rate_f32 = SAMPLE_RATE as f32;

    let tone_val = Arc::default();
    let tone = AtomicSamples::new(Arc::clone(&tone_val));

    let gate_val = Arc::default();
    let gate = AtomicSamples::new(Arc::clone(&gate_val));

    let wobble =
        ValueControlledOszilator::new(ConstSampleSource::new(-8.0), sample_rate_f32, SinWave)
            .amplify(0.02);

    let adsr = AdsrEnvelope::new(
        gate,
        AdsrParameter {
            attack: 0.01,
            decay: 0.0001,
            sustain: 0.4,
            release: 0.0001,
        },
    );

    let source = Arc::new(Mutex::new(Multiplier::<16, _, _>::new(
        Multiplier::new(
            ValueControlledOszilator::new(Mixer::new(tone.clone(), wobble), sample_rate_f32, |v| {
                //f32::sin(v * 3.141 * 2.)
                //f32::cos(v * 3.141)
                //-1.0 + v * 2.0

                if v < 0.5 {
                    1.0 - v * 2.0
                } else {
                    -1.0 + (v - 0.5) * 2.0
                }

                //if v < 0.5 {
                //    (v - 0.25) * 4.
                //} else {
                //    (v - 0.75) * -4.
                //}
            }),
            //ValueControlledOszilator::new(
            //    Mixer::new(tone.clone(), ConstSampleSource::new(0.05)),
            //    sample_rate_f32,
            //),
            adsr,
        ),
        ConstSampleSource::new(0.5),
    )));

    let queue = Arc::new(Mutex::new(VecDeque::with_capacity(1024)));
    let display_dequeue_audio = Arc::new(Mutex::new(VecDeque::with_capacity(1024)));
    let display_dequeue = Arc::clone(&display_dequeue_audio);
    let audio_output = AudioOutput::start(move |buffer| {
        let mut queue = queue.lock().unwrap();
        let mut display_dequeue = display_dequeue_audio.lock().unwrap();

        while queue.len() < buffer.len() {
            let samples = source.lock().unwrap().get_samples();
            queue.extend(samples.into_iter());
            while display_dequeue.len() >= display_dequeue.capacity() / 2 {
                std::mem::drop(display_dequeue.pop_front());
            }
            display_dequeue.extend(samples.into_iter());
        }

        for sample in buffer.iter_mut() {
            *sample = queue.pop_front().expect("queue is filled");
        }
    })
    .unwrap();

    const WIDTH: usize = 128;
    const HEIGHT: usize = 64;

    let mut screen = Screen::new(WIDTH, HEIGHT);

    let mut window = Window::new(
        "Synthesizer",
        WIDTH,
        HEIGHT,
        WindowOptions {
            scale: minifb::Scale::X4,
            ..WindowOptions::default()
        },
    )
    .unwrap_or_else(|e| panic!("{:?}", e));

    window.limit_update_rate(Some(std::time::Duration::from_micros(16600)));

    while window.is_open() && !window.is_key_down(Key::Escape) {
        gate_val.store(
            if let Some(cv) = window
                .get_keys()
                .into_iter()
                .filter_map(key_to_tone)
                .map(|v| v - 1.0)
                .next()
            {
                tone_val.store(ControlVoltage(I16F16::from_num(cv)));
                ControlVoltage(I16F16::from_num(1))
            } else {
                ControlVoltage(I16F16::from_num(0))
            },
        );

        draw(&mut screen, &display_dequeue.lock().unwrap());

        // We unwrap here as we want this code to exit if it fails. Real applications may want to handle this in a different way
        window
            .update_with_buffer(screen.buffer(), WIDTH, HEIGHT)
            .unwrap();
    }

    drop(audio_output);
}
