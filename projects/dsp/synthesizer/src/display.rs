#![allow(clippy::as_conversions, clippy::integer_arithmetic)]
#![allow(clippy::unreadable_literal)]

use embedded_graphics::{
    mono_font::{
        iso_8859_1::{FONT_6X10, FONT_7X13_BOLD},
        MonoTextStyle,
    },
    pixelcolor::BinaryColor,
    prelude::{Dimensions, DrawTarget, Point, Size},
    primitives::{Polyline, Primitive, PrimitiveStyle, Rectangle, StyledDrawable},
    text::Text,
    transform::Transform,
    Drawable, Pixel,
};

use std::collections::VecDeque;

pub struct Screen {
    buffer: Vec<u32>,
    width: usize,
    height: usize,
}

impl Screen {
    pub fn new(width: usize, height: usize) -> Self {
        Self {
            buffer: vec![0; width * height],
            width,
            height,
        }
    }

    pub fn buffer(&self) -> &[u32] {
        &self.buffer
    }
}

impl Dimensions for Screen {
    fn bounding_box(&self) -> Rectangle {
        Rectangle::new(
            Point::new(0, 0),
            Size::new(self.width as u32, self.height as u32),
        )
    }
}

impl DrawTarget for Screen {
    type Color = BinaryColor;
    type Error = ();

    fn draw_iter<I>(&mut self, pixels: I) -> Result<(), Self::Error>
    where
        I: IntoIterator<Item = Pixel<Self::Color>>,
    {
        for Pixel(Point { x, y }, color) in pixels {
            if x >= 0 && y >= 0 && x < self.width as i32 && y < self.height as i32 {
                self.buffer[x as usize + self.width * y as usize] = match color {
                    BinaryColor::On => 0xffffff,
                    BinaryColor::Off => 0x000000,
                }
            }
        }

        Ok(())
    }
}

#[allow(clippy::as_conversions)]
pub fn draw(display: &mut Screen, display_dequeue: &VecDeque<f32>) {
    let title_font = &FONT_7X13_BOLD;
    let title_style = MonoTextStyle::new(title_font, BinaryColor::On);

    let subtitle_font = &FONT_6X10;
    let subtitle_style = MonoTextStyle::new(subtitle_font, BinaryColor::On);

    display
        .bounding_box()
        .into_styled(PrimitiveStyle::with_fill(BinaryColor::Off))
        .draw(display)
        .expect("drawing to display works");

    Text::with_alignment(
        "RAPPET INSTRUMENTS",
        Point::new(display.width as i32 / 2, title_font.baseline as i32),
        title_style,
        embedded_graphics::text::Alignment::Center,
    )
    .draw(display)
    .expect("drawing to display works");
    Text::with_alignment(
        "Synthesizer",
        Point::new(
            display.width as i32 / 2,
            title_font.baseline as i32 + subtitle_font.character_size.height as i32,
        ),
        subtitle_style,
        embedded_graphics::text::Alignment::Center,
    )
    .draw(display)
    .expect("drawing to display works");

    let line_style = PrimitiveStyle::with_stroke(BinaryColor::On, 1);

    let fonts_height =
        title_font.character_size.height as i32 + subtitle_font.character_size.height as i32;
    let offset = fonts_height + (display.height as i32 - fonts_height) / 2;

    let step_size = 2;

    let samples = display_dequeue
        .iter()
        .step_by(step_size)
        .take(128)
        .map(|v| (*v * 48.) as i32);
    let points: Vec<_> = samples
        .into_iter()
        .enumerate()
        .map(|(i, v)| Point::new(i as i32, -v))
        .collect();

    Polyline::new(&points)
        .translate(Point::new(0, offset))
        .draw_styled(&line_style, display)
        .expect("drawing to display works");
}
