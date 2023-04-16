use std::f32::consts::PI;

pub struct WindowFunction {
    buffer: Box<[f32]>,
}

impl WindowFunction {
    pub fn new_hann(size: usize) -> Self {
        let mut buffer = vec![0f32; size].into_boxed_slice();
        for (i, sample) in buffer.iter_mut().enumerate() {
            *sample = 0.5 - 0.5 * f32::cos(i as f32 / size as f32 * 2.0 * PI);
        }
        WindowFunction { buffer }
    }

    pub fn new_hamming(size: usize) -> Self {
        let mut buffer = vec![0f32; size].into_boxed_slice();
        for (i, sample) in buffer.iter_mut().enumerate() {
            *sample = 0.54 - 0.46 * f32::cos(i as f32 / size as f32 * 2.0 * PI);
        }
        WindowFunction { buffer }
    }

    #[inline]
    pub fn apply(&self, data: &mut [f32]) {
        assert_eq!(data.len(), self.buffer.len());
        for (window, sample) in self.buffer.iter().zip(data.iter_mut()) {
            *sample *= *window;
        }
    }

    #[inline]
    pub fn size(&self) -> usize {
        self.buffer.len()
    }

    #[inline]
    pub fn buffer(&self) -> &[f32] {
        &self.buffer
    }
}
