//! Buffered sources of samples

use std::{cell::RefCell, f32::consts::TAU, rc::Rc};

const NOTE_A4_FREQUENCY: f32 = 440.0;

#[allow(clippy::module_name_repetitions)]
pub trait SampleSource<const LENGTH: usize>: Sized {
    /// Fills the provided buffer with samples
    fn get_samples(&mut self, sample_rate: f32) -> [f32; LENGTH];

    fn amplify(
        self,
        value: f32,
    ) -> ValueControlledAmplifier<LENGTH, Self, ConstSampleSource<LENGTH>> {
        ValueControlledAmplifier::new(self, ConstSampleSource::new(value))
    }

    fn mix<Other: SampleSource<LENGTH>>(self, other: Other) -> Mixer<LENGTH, Self, Other> {
        Mixer::new(self, other)
    }
}

#[allow(clippy::module_name_repetitions)]
pub struct ConstSampleSource<const LENGTH: usize> {
    value: f32,
}

impl<const LENGHT: usize> ConstSampleSource<LENGHT> {
    pub const fn new(value: f32) -> Self {
        Self { value }
    }
}

impl<const LENGTH: usize> SampleSource<LENGTH> for ConstSampleSource<LENGTH> {
    fn get_samples(&mut self, _sample_rate: f32) -> [f32; LENGTH] {
        [self.value; LENGTH]
    }
}

pub struct ValueControlledOszilator<const LENGTH: usize, Source> {
    pub pitch: Source,
    /// Wrapping progress of the oszilator.
    /// Value range is [0..1) representing one period.
    progress: f32,
}

impl<const LENGTH: usize, Source: SampleSource<LENGTH>> ValueControlledOszilator<LENGTH, Source> {
    pub const fn new(pitch: Source) -> Self {
        Self {
            pitch,
            progress: 0.0,
        }
    }
}

impl<const LENGTH: usize, Source: SampleSource<LENGTH>> SampleSource<LENGTH>
for ValueControlledOszilator<LENGTH, Source>
{
    fn get_samples(&mut self, sample_rate: f32) -> [f32; LENGTH] {
        let mut output_buffer = [0.0; LENGTH];
        let pitch_buffer = self.pitch.get_samples(sample_rate);

        for (pitch, sample) in pitch_buffer.iter().zip(output_buffer.iter_mut()) {
            let frequency = f32::exp2(*pitch) * NOTE_A4_FREQUENCY;
            let step = frequency / sample_rate;
            self.progress = (self.progress + step) % 1.0;
            *sample = f32::sin(self.progress * TAU);
        }
        output_buffer
    }
}

pub struct Sequencer<const LENGTH: usize> {
    pub sequence: Vec<f32>,
    pub current_note: usize,
    pub current_pos: f32,
    pub note_length: f32,
    pub gate_fraction: f32,
    pub sample_rate: u32,
    pub tone_buffer: [f32; LENGTH],
    pub gate_buffer: [f32; LENGTH],
    pub frame_count: usize,
}

impl<const LENGTH: usize> Sequencer<LENGTH> {
    pub fn new(
        sequence: Vec<f32>,
        note_length: f32,
        gate_fraction: f32,
        sample_rate: u32,
    ) -> Self {
        Self {
            sequence,
            current_note: 0,
            current_pos: 0.0,
            note_length,
            gate_fraction,
            sample_rate,
            tone_buffer: [0.0; LENGTH],
            gate_buffer: [0.0; LENGTH],
            frame_count: 0,
        }

    }

    pub fn parts(self) -> (SequencerTonePart<LENGTH>, SequencerGatePart<LENGTH>) {
        let shared = Rc::new(RefCell::new(self));
        (
            SequencerTonePart {
                sequencer: shared.clone(),
                frame: 0,
            },
            SequencerGatePart {
                sequencer: shared,
                frame: 0,
            },
        )
    }

    fn forward(&mut self) {
        #[allow(clippy::as_conversions, clippy::cast_precision_loss)]
        let sample_rate = self.sample_rate as f32;

        for (tone, gate) in self.tone_buffer.iter_mut().zip(self.gate_buffer.iter_mut()) {
            self.current_pos += 1. / self.note_length / sample_rate;
            if self.current_pos >= 1.0 {
                self.current_pos -= 1.0;
                self.current_note = self.current_note.saturating_add(1).checked_rem(self.sequence.len()).unwrap_or(0);
            }
            *tone = self.sequence[self.current_note];
            *gate = if self.current_pos < self.gate_fraction {
                1.0
            } else {
                0.0
            }
        }

        self.frame_count = self.frame_count.wrapping_add(1);
    }
}

pub struct SequencerTonePart<const LENGHT: usize> {
    sequencer: Rc<RefCell<Sequencer<LENGHT>>>,
    frame: usize,
}

impl<const LENGTH: usize> SampleSource<LENGTH> for SequencerTonePart<LENGTH> {
    fn get_samples(&mut self, _sample_rate: f32) -> [f32; LENGTH] {
        let mut sequencer = self.sequencer.borrow_mut();
        self.frame = self.frame.wrapping_add(1);
        if sequencer.frame_count != self.frame {
            sequencer.forward();
        }
        sequencer.tone_buffer
    }
}

pub struct SequencerGatePart<const LENGTH: usize> {
    sequencer: Rc<RefCell<Sequencer<LENGTH>>>,
    frame: usize,
}

impl<const LENGTH: usize> SampleSource<LENGTH> for SequencerGatePart<LENGTH> {
    fn get_samples(&mut self, _sample_rate: f32) -> [f32; LENGTH] {
        let mut sequencer = self.sequencer.borrow_mut();
        self.frame = self.frame.wrapping_add(1);
        if sequencer.frame_count != self.frame {
            sequencer.forward();
        }
        sequencer.gate_buffer
    }
}

pub struct ValueControlledAmplifier<const LENGTH: usize, Source, Amplification> {
    source: Source,
    amplification: Amplification,
}

impl<const LENGTH: usize, Source, Amplification>
ValueControlledAmplifier<LENGTH, Source, Amplification>
{
    pub const fn new(source: Source, amplification: Amplification) -> Self {
        Self {
            source,
            amplification,
        }
    }
}

impl<const LENGTH: usize, Source, Amplification> SampleSource<LENGTH>
for ValueControlledAmplifier<LENGTH, Source, Amplification>
where
    Source: SampleSource<LENGTH>,
    Amplification: SampleSource<LENGTH>,
{
    fn get_samples(&mut self, sample_rate: f32) -> [f32; LENGTH] {
        let mut output_buffer = [0.0; LENGTH];
        let source = self.source.get_samples(sample_rate);
        let amplification = self.amplification.get_samples(sample_rate);

        for ((output, sample), amplification) in output_buffer
            .iter_mut()
                .zip(source.iter())
                .zip(amplification.iter())
                {
                    *output = sample * amplification;
                }
        output_buffer
    }
}

pub struct Mixer<const LENGTH: usize, A, B> {
    a: A,
    b: B,
}

impl<const LENGTH: usize, A, B> Mixer<LENGTH, A, B>
where
    A: SampleSource<LENGTH>,
    B: SampleSource<LENGTH>,
{
    pub const fn new(a: A, b: B) -> Self {
        Self { a, b }
    }
}

impl<const LENGTH: usize, A, B> SampleSource<LENGTH> for Mixer<LENGTH, A, B>
where
    A: SampleSource<LENGTH>,
    B: SampleSource<LENGTH>,
{
    fn get_samples(&mut self, sample_rate: f32) -> [f32; LENGTH] {
        let mut output_buffer = [0.0; LENGTH];
        let a_buf = self.a.get_samples(sample_rate);
        let b_buf = self.b.get_samples(sample_rate);
        for (dest, (a, b)) in output_buffer.iter_mut().zip(a_buf.iter().zip(b_buf.iter())) {
            *dest = a + b;
        }
        output_buffer
    }
}

#[allow(dead_code)]
pub struct AdsrParameter {
    pub attack_time: f32,
    pub decay_time: f32,
    pub sustain_level: f32,
    pub release_time: f32,
}

#[allow(dead_code)]
enum AdsrPhase {
    Idle,
    Attack,
    Decay,
    Sustain,
    Release,
}
