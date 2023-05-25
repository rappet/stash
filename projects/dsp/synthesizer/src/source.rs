//! Buffered sources of samples

use dsp_lib::streaming::SampleSource;

use alloc::sync::Arc;
use core::f32::consts::TAU;
use fixed::traits::LossyFrom;
use spin::Mutex;

use crate::parameter::{ControlVoltage, Parameter};

const NOTE_A4_FREQUENCY: f32 = 220.0;

pub struct ValueControlledOszilator<const LENGTH: usize, Source, W: Wave> {
    pub pitch: Source,
    pub sample_rate: f32,
    /// Wrapping progress of the oszilator.
    /// Value range is [0..1) representing one period.
    progress: f32,
    wave: W,
}

impl<const LENGTH: usize, Source: SampleSource<LENGTH>, W: Wave>
    ValueControlledOszilator<LENGTH, Source, W>
{
    pub const fn new(pitch: Source, sample_rate: f32, wave: W) -> Self {
        Self {
            pitch,
            sample_rate,
            progress: 0.0,
            wave,
        }
    }
}

pub trait Wave {
    /// Get one sample
    ///
    /// # Parameters
    /// Progress between 0.0 and 1.0
    ///
    /// # Returns
    /// Value between -1.0 and 1.0
    fn get_sample(&self, progress: f32) -> f32;
}

#[derive(Default, Clone, Copy)]
pub struct SinWave;

impl Wave for SinWave {
    #[inline]
    fn get_sample(&self, progress: f32) -> f32 {
        f32::sin(progress * TAU)
    }
}

impl<F: Fn(f32) -> f32> Wave for F {
    #[inline]
    fn get_sample(&self, progress: f32) -> f32 {
        self(progress)
    }
}

impl<const LENGTH: usize, Source: SampleSource<LENGTH>, W: Wave> SampleSource<LENGTH>
    for ValueControlledOszilator<LENGTH, Source, W>
{
    fn get_samples(&mut self) -> [f32; LENGTH] {
        let mut output_buffer = [0.0; LENGTH];
        let pitch_buffer = self.pitch.get_samples();

        for (pitch, sample) in pitch_buffer.iter().zip(output_buffer.iter_mut()) {
            let frequency = f32::exp2(*pitch) * NOTE_A4_FREQUENCY;
            let step = frequency / self.sample_rate;
            self.progress = (self.progress + step) % 1.0;
            *sample = self.wave.get_sample(self.progress);
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
    /// Create a sequencer
    ///
    /// # Arguments
    ///
    /// * `sequence` of tones to be played
    ///
    /// * `note_length` length of a whole single note
    ///
    /// * `gate_fraction` fraction of the note where the gate is one
    ///
    /// * `sample_rate` sample rate in Hz
    ///
    pub fn new(sequence: Vec<f32>, note_length: f32, gate_fraction: f32, sample_rate: u32) -> Self {
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

    /// Split to two parts. Both parts should be polled together after eachother.
    pub fn parts(self) -> (SequencerTonePart<LENGTH>, SequencerGatePart<LENGTH>) {
        let shared = Arc::new(Mutex::new(self));
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
                self.current_note = self
                    .current_note
                    .saturating_add(1)
                    .checked_rem(self.sequence.len())
                    .unwrap_or(0);
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
    sequencer: Arc<Mutex<Sequencer<LENGHT>>>,
    frame: usize,
}

impl<const LENGTH: usize> SampleSource<LENGTH> for SequencerTonePart<LENGTH> {
    fn get_samples(&mut self) -> [f32; LENGTH] {
        let mut sequencer = self.sequencer.try_lock().unwrap();
        self.frame = self.frame.wrapping_add(1);
        if sequencer.frame_count != self.frame {
            sequencer.forward();
        }
        sequencer.tone_buffer
    }
}

pub struct SequencerGatePart<const LENGTH: usize> {
    sequencer: Arc<Mutex<Sequencer<LENGTH>>>,
    frame: usize,
}

impl<const LENGTH: usize> SampleSource<LENGTH> for SequencerGatePart<LENGTH> {
    fn get_samples(&mut self) -> [f32; LENGTH] {
        let mut sequencer = self.sequencer.try_lock().unwrap();
        self.frame = self.frame.wrapping_add(1);
        if sequencer.frame_count != self.frame {
            sequencer.forward();
        }
        sequencer.gate_buffer
    }
}

#[derive(Clone)]
pub struct AtomicSamples {
    value: Arc<Parameter<ControlVoltage>>,
}

impl AtomicSamples {
    pub fn new(value: Arc<Parameter<ControlVoltage>>) -> Self {
        Self { value }
    }
}

impl<const LENGTH: usize> SampleSource<LENGTH> for AtomicSamples {
    fn get_samples(&mut self) -> [f32; LENGTH] {
        let sample = f32::lossy_from(self.value.load().0);
        let mut samples = [0f32; LENGTH];
        samples.iter_mut().for_each(|s| *s = sample);
        samples
    }
}

#[derive(Debug, Clone, Copy)]
pub struct AdsrParameter {
    pub attack: f32,
    pub decay: f32,
    pub sustain: f32,
    pub release: f32,
}

pub struct AdsrEnvelope<const LENGTH: usize, Gate> {
    pub gate: Gate,
    value: f32,
    attack_finished: bool,
    parameters: AdsrParameter,
}

impl<const LENGTH: usize, Gate> AdsrEnvelope<LENGTH, Gate> {
    pub const fn new(gate: Gate, parameters: AdsrParameter) -> Self {
        Self {
            gate,
            value: 0.0,
            attack_finished: false,
            parameters,
        }
    }
}

impl<const LENGTH: usize, Gate: SampleSource<LENGTH>> SampleSource<LENGTH>
    for AdsrEnvelope<LENGTH, Gate>
{
    fn get_samples(&mut self) -> [f32; LENGTH] {
        let mut output_buffer = [0.0; LENGTH];
        let gate_buffer = self.gate.get_samples();

        let AdsrParameter {
            attack,
            decay,
            sustain,
            release,
        } = self.parameters;

        for (gate, sample) in gate_buffer
            .into_iter()
            .map(|gate| gate > 0.5)
            .zip(output_buffer.iter_mut())
        {
            if gate {
                if self.attack_finished {
                    self.value = (1.0 - decay) * self.value + decay * sustain;
                } else {
                    self.value = (1.0 - attack) * self.value + attack;
                    if self.value > 0.95 {
                        self.attack_finished = true;
                    }
                }
            } else {
                self.attack_finished = false;
                self.value = (1.0 - release) * self.value;
            }

            *sample = self.value;
        }

        output_buffer
    }
}
