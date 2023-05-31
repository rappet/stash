#![deny(clippy::all)]
#![warn(clippy::pedantic)]
#![warn(clippy::nursery)]
#![deny(clippy::integer_arithmetic)]
#![deny(clippy::as_conversions)]

extern crate alloc;

use audio_output::AudioOutput;
use dsp_lib::streaming::SampleSource;
use fixed::types::I16F16;

use std::{collections::VecDeque, sync::Arc, sync::Mutex, usize};

use minifb::{Key, Window, WindowOptions};
use source::AdsrParameter;

use crate::display::{draw, Screen};
use crate::parameter::{ControlValue, Parameter};
use crate::synthesizer::{Synthesizer, SynthesizerParams};

mod audio_output;
mod display;
mod parameter;
mod source;
mod synthesizer;

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
    const WIDTH: usize = 128;
    const HEIGHT: usize = 64;

    let params = SynthesizerParams {
        tone: Arc::default(),
        gate: Arc::default(),
        adsr: Arc::new(AdsrParameter {
            attack: Parameter::new(0.01),
            decay: Parameter::new(0.0001),
            sustain: Parameter::new(0.4),
            release: Parameter::new(0.0001),
        }),
    };

    let synthesizer = Arc::new(Mutex::new(Synthesizer::new(params.clone(), SAMPLE_RATE)));

    let queue = Arc::new(Mutex::new(VecDeque::with_capacity(1024)));
    let display_dequeue_audio = Arc::new(Mutex::new(VecDeque::with_capacity(1024)));
    let display_dequeue = Arc::clone(&display_dequeue_audio);
    let audio_output = AudioOutput::start(move |buffer| {
        let mut queue = queue.lock().unwrap();
        let mut display_dequeue = display_dequeue_audio.lock().unwrap();

        while queue.len() < buffer.len() {
            let samples: [_; 64] = synthesizer.lock().unwrap().get_samples();
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
    .unwrap_or_else(|e| panic!("{e:?}"));

    window.limit_update_rate(Some(std::time::Duration::from_micros(16600)));

    while window.is_open() && !window.is_key_down(Key::Escape) {
        params.gate.store(
            if let Some(cv) = window
                .get_keys()
                .into_iter()
                .filter_map(key_to_tone)
                .map(|v| v - 1.0)
                .next()
            {
                params.tone.store(ControlValue(I16F16::from_num(cv)));
                ControlValue(I16F16::from_num(1))
            } else {
                ControlValue(I16F16::from_num(0))
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
