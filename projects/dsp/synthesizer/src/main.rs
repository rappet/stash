#![deny(clippy::all)]
#![warn(clippy::pedantic)]
#![warn(clippy::nursery)]
#![deny(clippy::integer_arithmetic)]
#![deny(clippy::as_conversions)]

extern crate alloc;

use audio_output::AudioOutput;
use dsp_lib::streaming::{ConstSampleSource, Mixer, Multiplier, SampleSource};

use std::{
    collections::VecDeque,
    fs::File,
    io,
    sync::Arc,
    sync::{mpsc, Mutex},
    thread,
    time::Duration,
    usize,
};

use atomic_float::AtomicF32;
use source::{
    AdsrEnvelope, AdsrParameter, AtomicSampleSource, Sequencer, ValueControlledOszilator,
};

mod audio_output;
mod source;

const SAMPLE_RATE: u32 = 44_100;
const FRAME_SIZE: usize = 32;

fn main() {
    #[allow(clippy::as_conversions, clippy::cast_precision_loss)]
    let sample_rate_f32 = SAMPLE_RATE as f32;

    let (tone, gate) = Sequencer::<FRAME_SIZE>::new(
        vec![0.0 / 12.0, 1.0 / 12.0, 2.0 / 12.0, 3.0 / 12.0],
        1. / 2.,
        0.7,
        SAMPLE_RATE,
    )
    .parts();

    let wobble = ValueControlledOszilator::new(ConstSampleSource::<32>::new(-4.3), sample_rate_f32)
        .amplify(0.03);

    let adsr = AdsrEnvelope::new(
        gate,
        AdsrParameter {
            attack_time: usize::try_from(SAMPLE_RATE).unwrap() / 32,
            decay_time: usize::try_from(SAMPLE_RATE).unwrap() / 16,
            sustain_level: 0.4,
            release_time: usize::try_from(SAMPLE_RATE).unwrap() / 2,
        },
    );

    let mut source = Arc::new(Mutex::new(Multiplier::new(
        ValueControlledOszilator::new(Mixer::new(tone, wobble), sample_rate_f32),
        adsr,
    )));

    let mut queue = Arc::new(Mutex::new(VecDeque::with_capacity(1024)));
    let mut audio_output = AudioOutput::start(move |buffer| {
        let mut queue = queue.lock().unwrap();

        while queue.len() < buffer.len() {
            queue.extend(source.lock().unwrap().get_samples().into_iter());
        }

        for sample in buffer.iter_mut() {
            *sample = queue.pop_front().expect("queue is filled");
        }
    })
    .unwrap();

    loop {
        thread::sleep(Duration::from_millis(100));
    }
}
