//! Everything for representing, storing and formatting
//! a `sRGB` color palette.
use std::io::{self, Write};

use serde::Serialize;

/// A color palette contianing multiple hues,
/// each with similar shades.
#[derive(Debug, Clone, Serialize)]
pub struct Palette {
    /// Name of the tones referenced in [`Self::hues`]
    pub tone_names: Vec<String>,
    /// List how hues, containing shades
    pub hues: Vec<Shades>,
}

/// A single hue and its shadres
#[derive(Debug, Clone, Serialize)]
pub struct Shades {
    /// Human readable name, for example "blue"
    pub hue_name: String,
    /// List of tones as named in [`Palette::tone_names`]
    pub tones: Vec<(u8, u8, u8)>,
}

impl Palette {
    /// Generate a CSS file containing CSS variable with the colors
    pub fn as_css_variables_file(&self) -> String {
        let mut out = Vec::new();
        self.write_as_css_variables_file(&mut out)
            .expect("Writing to a vec succeeds");
        String::from_utf8(out).expect("The generated string is always UTF-8")
    }

    fn write_as_css_variables_file(&self, mut out: impl Write) -> io::Result<()> {
        writeln!(&mut out, ":root {{")?;

        for hue in &self.hues {
            let hue_name = &hue.hue_name;
            writeln!(&mut out, "  /* {hue_name} */")?;
            for (tone_name, &(r, g, b)) in self.tone_names.iter().zip(hue.tones.iter()) {
                writeln!(
                    &mut out,
                    "  --{hue_name}-{tone_name}: #{r:02x}{g:02x}{b:02x};"
                )?;
            }
        }

        writeln!(&mut out, "}}")?;

        Ok(())
    }
}
