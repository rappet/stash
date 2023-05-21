use anyhow::{Context, Result};
use cpal::traits::{DeviceTrait, HostTrait, StreamTrait};
use cpal::{FromSample, Sample, SampleFormat, SampleRate, Stream};
use std::iter::repeat;

const SAMPLE_RATE: u32 = 44_100;

pub struct AudioOutput {
    output_stream: Stream,
}

impl AudioOutput {
    pub fn start<W>(write_callback: W) -> Result<Self>
    where
        W: Fn(&mut [f32]) + Send + 'static,
    {
        let host = cpal::default_host();

        let output_device = host
            .default_output_device()
            .context("could not find the default audio output device")?;
        println!(
            "Output device: {}",
            output_device.name().unwrap_or_default()
        );

        let supported_output_config = output_device
            .default_output_config()
            .context("could not get the default config for the output device")?;
        let mut output_config = supported_output_config.config();
        output_config.channels = 1;
        output_config.sample_rate = SampleRate(SAMPLE_RATE);

        println!("Output config: {output_config:?}");

        let output_stream = match supported_output_config.sample_format() {
            SampleFormat::F32 => output_device.build_output_stream(
                &output_config,
                create_write_callback::<_, f32>(write_callback),
                |_| {},
                None,
            ),
            SampleFormat::I16 => output_device.build_output_stream(
                &output_config,
                create_write_callback::<_, i16>(write_callback),
                |_| {},
                None,
            ),
            SampleFormat::U16 => output_device.build_output_stream(
                &output_config,
                create_write_callback::<_, u16>(write_callback),
                |_| {},
                None,
            ),
            _ => panic!(),
        }
        .context("could not create output stream")?;
        output_stream
            .play()
            .context("can not start the output stream")?;

        Ok(Self { output_stream })
    }

    pub fn stop(self) {
        self.output_stream.pause().unwrap();
    }
}

fn create_write_callback<CB, T>(
    write_callback: CB,
) -> impl FnMut(&mut [T], &cpal::OutputCallbackInfo)
where
    CB: Fn(&mut [f32]),
    T: Sample + cpal::FromSample<i16> + cpal::FromSample<f32>,
{
    move |buffer, _info| {
        let mut write_scratch_buff = [0f32; 4096];
        let write_scratch = &mut write_scratch_buff[0..buffer.len()];
        write_callback(write_scratch);
        for (read, write) in write_scratch.iter().copied().zip(buffer.iter_mut()) {
            *write = T::from_sample(read);
        }
    }
}
