#![deny(clippy::all)]
#![warn(clippy::pedantic)]
#![warn(clippy::nursery)]
#![deny(clippy::integer_arithmetic)]
#![deny(clippy::as_conversions)]

use dsp_lib::streaming::{ConstSampleSource, Mixer, Multiplier, SampleSource};

use std::{fs::File, usize};

use source::{Sequencer, ValueControlledOszilator};
use wav::{BitDepth, Header, WAV_FORMAT_IEEE_FLOAT};

mod source;

const SAMPLE_RATE_CD: u32 = 44_100;
const FRAME_SIZE: usize = 32;

fn main() {
    #[allow(clippy::as_conversions, clippy::cast_precision_loss)]
    let sample_rate_f32 = SAMPLE_RATE_CD as f32;

    let (tone, gate) = Sequencer::<FRAME_SIZE>::new(
        vec![0.0 / 12.0, 1.0 / 12.0, 2.0 / 12.0, 3.0 / 12.0],
        1. / 4.,
        0.9,
        SAMPLE_RATE_CD,
    )
    .parts();

    let wobble =
        ValueControlledOszilator::new(ConstSampleSource::new(-4.0), sample_rate_f32).amplify(0.03);

    let mut source = Multiplier::new(
        ValueControlledOszilator::new(Mixer::new(tone, wobble), sample_rate_f32),
        gate,
    );

    #[allow(clippy::as_conversions, clippy::integer_arithmetic)]
    let mut out = vec![0.0; SAMPLE_RATE_CD as usize * 10];

    for frame in out.chunks_mut(FRAME_SIZE) {
        let len = frame.len();
        frame.copy_from_slice(&source.get_samples()[..len]);
    }

    let header = Header::new(WAV_FORMAT_IEEE_FLOAT, 1, SAMPLE_RATE_CD, 32);
    let data = BitDepth::ThirtyTwoFloat(Vec::from(out.as_slice()));
    let mut out_file = File::create("out.wav").unwrap();
    wav::write(header, &data, &mut out_file).unwrap();
}
