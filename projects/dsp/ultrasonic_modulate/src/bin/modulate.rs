use std::f32::consts::PI;
use std::fs::File;
use std::io::Write;
use wav::{BitDepth, WAV_FORMAT_IEEE_FLOAT};

const SAMPLE_RATE: u32 = 48000;
const FREQUENCY: u32 = 18_000;
const FRAMES_PER_SEC: u32 = 100;
const SAMPLES_PER_FRAME: u32 = SAMPLE_RATE / FRAMES_PER_SEC;

fn main() {
    let preamble = &[
        0, 255, 0, 255, 0b10101010, 0b01010101, 0b10101010, 0b01010101,
    ];
    let message = "Hello, World!";

    let mut signal: Vec<u8> = Vec::new();
    signal.extend_from_slice(preamble);
    signal.extend_from_slice(message.as_bytes());
    signal.extend_from_slice(b"\0\0\0\0");

    println!("{}", signal.len());

    let bits: Vec<_> = signal
        .iter()
        .map(|&symbol| {
            let mut bits_symbol = [false; 16];
            for i in 0..8 {
                if (symbol & (1 << i)) != 0 {
                    bits_symbol[i] = true;
                    bits_symbol[i + 8] = true;
                }
            }
            bits_symbol
        })
        .collect();

    let single: Vec<f32> = bits
        .iter()
        .flat_map(|bits_symbol| encode_frame(bits_symbol))
        .collect();

    let mut all: Vec<f32> = Vec::with_capacity(single.len() * 1000);
    for _ in 0..1000 {
        all.extend_from_slice(single.as_slice());
    }

    let header = wav::Header {
        audio_format: WAV_FORMAT_IEEE_FLOAT,
        channel_count: 1,
        sampling_rate: SAMPLE_RATE,
        bytes_per_second: SAMPLE_RATE * 4,
        bytes_per_sample: 4,
        bits_per_sample: 32,
    };

    let file_name = format!("sinus-{FREQUENCY}.wav");
    let mut file = File::create(file_name).unwrap();
    wav::write(header, &BitDepth::ThirtyTwoFloat(all), &mut file).unwrap();
    file.flush().unwrap();
}

fn encode_frame(bits: &[bool]) -> Vec<f32> {
    (0..SAMPLES_PER_FRAME)
        .map(|n| n as f32 / SAMPLES_PER_FRAME as f32)
        .map(|t| {
            let t_sec = t / FRAMES_PER_SEC as f32;
            let envelope = 0.5 - 0.5 * f32::cos(2.0 * PI * t);

            let mut sample = 0.0;

            for (bit_nr, &bit) in bits.iter().enumerate() {
                if bit {
                    let carrier_frequency = (FREQUENCY + FRAMES_PER_SEC * bit_nr as u32 * 2) as f32;
                    sample += f32::sin(t_sec * 2.0 * PI * carrier_frequency);
                }
            }

            sample * envelope / 16.0
            //sample / 16.0
        })
        .collect()
}
