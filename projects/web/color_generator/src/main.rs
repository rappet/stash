#![doc = include_str!("../README.md")]
#![deny(clippy::all)]
#![warn(clippy::pedantic)]
//#![warn(clippy::restriction)]
#![warn(clippy::nursery)]
// allows
//#![allow(clippy::blanket_clippy_restriction_lints)]
#![allow(clippy::expect_used)]
#![allow(clippy::question_mark_used)]
#![allow(clippy::blanket_clippy_restriction_lints)]
#![allow(clippy::float_arithmetic)]

use colors::{Palette, Shades};
use palette::{convert::TryFromColor, LinSrgb, OklabHue, Oklch, Srgb};

use crate::cli::OutputFormat;

mod colors;

mod cli {
    use argh::FromArgs;

    #[derive(FromArgs, Debug, PartialEq, Eq)]
    /// Top level command
    pub struct Args {
        #[argh(subcommand)]
        pub output_format: OutputFormat,
    }

    #[derive(FromArgs, Debug, PartialEq, Eq)]
    #[argh(subcommand)]
    pub enum OutputFormat {
        CssVariables(CssVariables),
    }

    #[derive(FromArgs, Debug, PartialEq, Eq)]
    /// Output CSS variables
    #[argh(subcommand, name = "css-variables")]
    pub struct CssVariables {}
}

const SHADE_COUNT: u16 = 10;

/// Generate `sRGB` colors from OKLAB colors
///
/// # Warning
/// For some reason the hue for these colors is off
/// and does not correspond to the web colors.
///
/// # Returns
/// None in case the specified color would not be representable in `sRGB`
#[must_use]
pub fn try_from_oklch(luma: f32, chroma: f32, hue_degrees: f32) -> Option<(u8, u8, u8)> {
    let oklch = Oklch::new(luma, chroma, OklabHue::from_degrees(hue_degrees));
    let lin_rgb = LinSrgb::try_from_color(oklch).ok()?;
    let srgb = Srgb::<u8>::from_linear(lin_rgb);
    Some((srgb.red, srgb.green, srgb.blue))
}

#[must_use]
pub fn shades(luma_max: f32, hue_degrees: f32) -> Option<Vec<(u8, u8, u8)>> {
    let shades: Option<Vec<_>> = (0..SHADE_COUNT)
        .map(|i| {
            (
                f32::from(i) / f32::from(SHADE_COUNT - 1) * luma_max,
                f32::from(i) / f32::from(SHADE_COUNT - 1) * 0.12,
            )
        })
        .map(|(luma, chroma)| try_from_oklch(luma, chroma, hue_degrees))
        .collect();
    shades
}

fn main() {
    let args: cli::Args = argh::from_env();

    let colors = Palette {
        tone_names: (0..SHADE_COUNT).map(|shade| format!("{shade}")).collect(),
        hues: vec![Shades {
            hue_name: "red".into(),
            tones: shades(0.7, 268.65)
                .expect("All shades are possible for compile time fixed parameters"),
        }],
    };

    match args.output_format {
        OutputFormat::CssVariables(_) => println!("{}", colors.as_css_variables_file()),
    }
}
