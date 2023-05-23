//! Streaming of time series samples

/// A source of samples that can always provide samples
pub trait SampleSource<const LENGTH: usize>: Sized {
    /// Fills the provided buffer with samples
    fn get_samples(&mut self) -> [f32; LENGTH];

    /// Wrap the `SampleSource` with an amplififier of const value
    fn amplify(self, value: f32) -> Multiplier<LENGTH, Self, ConstSampleSource<LENGTH>> {
        Multiplier::new(self, ConstSampleSource::new(value))
    }

    /// Mix both sources together
    fn mix<Other: SampleSource<LENGTH>>(self, other: Other) -> Mixer<LENGTH, Self, Other> {
        Mixer::new(self, other)
    }
}

/// A source of constant values
pub struct ConstSampleSource<const LENGTH: usize> {
    value: f32,
}

impl<const LENGHT: usize> ConstSampleSource<LENGHT> {
    #[must_use]
    /// Create a new source with a const DC value
    pub const fn new(value: f32) -> Self {
        Self { value }
    }
}

impl<const LENGTH: usize> SampleSource<LENGTH> for ConstSampleSource<LENGTH> {
    fn get_samples(&mut self) -> [f32; LENGTH] {
        [self.value; LENGTH]
    }
}

/// Multiplies a sample source with another
/// Also called "Voltage controlled amplifier" (VCO) for hardware synthesizers
pub struct Multiplier<const LENGTH: usize, Source, Amplification> {
    source: Source,
    amplification: Amplification,
}

impl<const LENGTH: usize, Source, Amplification> Multiplier<LENGTH, Source, Amplification> {
    /// Create a new vaule multiplier
    pub const fn new(source: Source, amplification: Amplification) -> Self {
        Self {
            source,
            amplification,
        }
    }
}

impl<const LENGTH: usize, Source, Amplification> SampleSource<LENGTH>
    for Multiplier<LENGTH, Source, Amplification>
where
    Source: SampleSource<LENGTH>,
    Amplification: SampleSource<LENGTH>,
{
    fn get_samples(&mut self) -> [f32; LENGTH] {
        let mut output_buffer = [0.0; LENGTH];
        let source = self.source.get_samples();
        let amplification = self.amplification.get_samples();

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

/// Mixes two sample sources together
pub struct Mixer<const LENGTH: usize, A, B> {
    a: A,
    b: B,
}

impl<const LENGTH: usize, A, B> Mixer<LENGTH, A, B>
where
    A: SampleSource<LENGTH>,
    B: SampleSource<LENGTH>,
{
    /// Create a new sample mixer
    pub const fn new(a: A, b: B) -> Self {
        Self { a, b }
    }
}

impl<const LENGTH: usize, A, B> SampleSource<LENGTH> for Mixer<LENGTH, A, B>
where
    A: SampleSource<LENGTH>,
    B: SampleSource<LENGTH>,
{
    fn get_samples(&mut self) -> [f32; LENGTH] {
        let mut output_buffer = [0.0; LENGTH];
        let a_buf = self.a.get_samples();
        let b_buf = self.b.get_samples();
        for (dest, (a, b)) in output_buffer.iter_mut().zip(a_buf.iter().zip(b_buf.iter())) {
            *dest = a + b;
        }
        output_buffer
    }
}
