//! Buffered sources of samples

use dsp_lib::streaming::SampleSource;

use std::{cell::RefCell, f32::consts::TAU, rc::Rc};

const NOTE_A4_FREQUENCY: f32 = 440.0;

pub struct ValueControlledOszilator<const LENGTH: usize, Source> {
    pub pitch: Source,
    pub sample_rate: f32,
    /// Wrapping progress of the oszilator.
    /// Value range is [0..1) representing one period.
    progress: f32,
}

impl<const LENGTH: usize, Source: SampleSource<LENGTH>> ValueControlledOszilator<LENGTH, Source> {
    pub const fn new(pitch: Source, sample_rate: f32) -> Self {
        Self {
            pitch,
            sample_rate,
            progress: 0.0,
        }
    }
}

impl<const LENGTH: usize, Source: SampleSource<LENGTH>> SampleSource<LENGTH>
    for ValueControlledOszilator<LENGTH, Source>
{
    fn get_samples(&mut self) -> [f32; LENGTH] {
        let mut output_buffer = [0.0; LENGTH];
        let pitch_buffer = self.pitch.get_samples();

        for (pitch, sample) in pitch_buffer.iter().zip(output_buffer.iter_mut()) {
            let frequency = f32::exp2(*pitch) * NOTE_A4_FREQUENCY;
            let step = frequency / self.sample_rate;
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
    sequencer: Rc<RefCell<Sequencer<LENGHT>>>,
    frame: usize,
}

impl<const LENGTH: usize> SampleSource<LENGTH> for SequencerTonePart<LENGTH> {
    fn get_samples(&mut self) -> [f32; LENGTH] {
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
    fn get_samples(&mut self) -> [f32; LENGTH] {
        let mut sequencer = self.sequencer.borrow_mut();
        self.frame = self.frame.wrapping_add(1);
        if sequencer.frame_count != self.frame {
            sequencer.forward();
        }
        sequencer.gate_buffer
    }
}

#[derive(Debug, Clone, Copy)]
pub struct AdsrParameter {
    pub attack_time: usize,
    pub decay_time: usize,
    pub sustain_level: f32,
    pub release_time: usize,
}

pub struct AdsrEnvelope<const LENGTH: usize, Gate> {
    pub gate: Gate,
    progress: usize,
    gate_status: bool,
    parameters: AdsrParameter,
}

impl<const LENGTH: usize, Gate> AdsrEnvelope<LENGTH, Gate> {
    pub const fn new(gate: Gate, parameters: AdsrParameter) -> Self {
        Self {
            gate,
            progress: 0,
            gate_status: false,
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

        for (gate, sample) in gate_buffer
            .into_iter()
            .map(|gate| gate > 0.5)
            .zip(output_buffer.iter_mut())
        {
            if self.gate_status == gate {
                self.progress = self.progress.wrapping_add(1);
            } else {
                self.gate_status = gate;
                self.progress = 0;
            }

            *sample = if gate {
                if self.progress < self.parameters.attack_time {
                    // attack
                    let progress = self.progress as f32;
                    let attack_time = self.parameters.attack_time as f32;
                    progress / attack_time
                } else if self.progress
                    < self
                        .parameters
                        .attack_time
                        .saturating_add(self.parameters.decay_time)
                {
                    // decay
                    let relative_progress =
                        self.progress.saturating_sub(self.parameters.attack_time) as f32
                            / self.parameters.decay_time as f32;
                    1.0 * (1.0 - relative_progress)
                        + self.parameters.sustain_level * relative_progress
                } else {
                    // sustain
                    self.parameters.sustain_level
                }
            } else {
                if self.progress < self.parameters.decay_time {
                    let progress = self.progress as f32;
                    let decay_time = self.parameters.decay_time as f32;
                    self.parameters.sustain_level
                        - (progress / decay_time) * self.parameters.sustain_level
                } else {
                    0.0
                }
            }
        }

        output_buffer
    }
}
