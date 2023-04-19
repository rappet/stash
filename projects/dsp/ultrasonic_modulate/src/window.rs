//! Window functions used for digital signal processing
//!
//! # Examples
//!
//! Using the [Hamming](`functions::hamming`) window:
//!
//! ```
//! # use ultrasonic_modulate::window::functions as functions;
//! # use ultrasonic_modulate::window::{WindowFunction, ComputedWindowFunction};
//! #
//! // Generate some data and a window with a static size
//! let mut data = [1.0; 512];
//! let window = ComputedWindowFunction::new(functions::hamming);
//!
//! window.apply(&mut data);
//! println!("{data:?}");
//! ```

/// A pre-computed window with a static size
pub struct ComputedWindowFunction<const LENGTH: usize> {
    buffer: [f32; LENGTH],
}

/// A function defining a window for signal processing
///
/// A good window function might be [`functions::hamming`]
///
/// # Examples
///
/// ```
/// # use ultrasonic_modulate::window::functions as functions;
/// # use ultrasonic_modulate::window::WindowFunction;
/// #
/// let sample = functions::hamming.window_sample(0.5);
/// assert!(f32::abs(sample - 1.0) < 0.001);
/// ```
pub trait WindowFunction {
    /// Compute the multiplication factor for a window function
    ///
    /// # Arguments
    ///
    /// * `x` = `n / M`, position in the window in the range [0.0, 1.0]
    fn window_sample(&self, x: f32) -> f32;
}

impl<F> WindowFunction for F
where
    F: Fn(f32) -> f32,
{
    fn window_sample(&self, x: f32) -> f32 {
        self(x)
    }
}

/// Common window functions
pub mod functions {
    use std::f32::consts::PI;

    pub fn hann(x: f32) -> f32 {
        0.5 - 0.5 * f32::cos(x * 2.0 * PI)
    }

    /// Very good general purpose window function
    ///
    /// Cancels first sidelobe of [Hann] window.
    ///
    /// [Hann]: `hann`
    pub fn hamming(x: f32) -> f32 {
        0.54 - 0.46 * f32::cos(x * 2.0 * PI)
    }
}

impl<const LENGTH: usize> ComputedWindowFunction<LENGTH> {
    /// Compute a window from a window function
    pub fn new(window_function: impl WindowFunction) -> Self {
        let mut buffer = [0f32; LENGTH];
        for (n, sample) in buffer.iter_mut().enumerate() {
            *sample = window_function.window_sample(n as f32 / LENGTH as f32);
        }
        ComputedWindowFunction { buffer }
    }

    #[inline]
    /// Apply the window to raw data
    pub fn apply(&self, data: &mut [f32; LENGTH]) {
        for (window, sample) in self.buffer.into_iter().zip(data.iter_mut()) {
            *sample *= window;
        }
    }

    #[inline]
    /// The precomputed buffer of the window function
    pub fn buffer(&self) -> &[f32] {
        &self.buffer
    }
}
