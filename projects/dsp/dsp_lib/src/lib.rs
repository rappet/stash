//! Generic building blocks for Digital Signal Processing (DSP)

#![deny(clippy::all)]
#![warn(clippy::pedantic)]
#![warn(clippy::nursery)]
// single warnings
#![deny(clippy::integer_arithmetic)]
#![warn(missing_docs, clippy::missing_errors_doc, clippy::missing_const_for_fn)]

pub mod streaming;
pub mod window;
