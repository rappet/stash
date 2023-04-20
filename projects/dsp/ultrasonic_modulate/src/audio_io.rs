use crate::SAMPLE_RATE;
use anyhow::{Context, Result};
use cpal::traits::{DeviceTrait, HostTrait, StreamTrait};
use cpal::{FromSample, Sample, SampleFormat, SampleRate, Stream};
use std::iter::repeat;

pub struct AudioIo {
    output_stream: Stream,
    input_stream: Stream,
}

impl AudioIo {
    pub fn start<W, R>(write_callback: W, read_callback: R) -> Result<AudioIo>
    where
        W: Fn(&mut [i16]) + Send + 'static,
        R: Fn(&[i16]) + Send + 'static,
    {
        let host = cpal::default_host();

        let output_device = host
            .default_output_device()
            .context("could not find the default audio output device")?;
        println!(
            "Output device: {}",
            output_device.name().unwrap_or_default()
        );
        let input_device = host
            .default_input_device()
            .context("could not find the default audio recording device")?;
        println!(
            "Recording device: {}",
            input_device.name().unwrap_or_default()
        );

        let supported_output_config = output_device
            .default_output_config()
            .context("could not get the default config for the output device")?;
        let mut output_config = supported_output_config.config();
        output_config.channels = 1;
        output_config.sample_rate = SampleRate(SAMPLE_RATE);
        let supported_input_config = input_device
            .default_input_config()
            .context("could not get the default config for the recording device")?;
        let mut input_config = supported_input_config.config();
        input_config.channels = 1;
        input_config.sample_rate = SampleRate(SAMPLE_RATE);

        println!("Output config: {output_config:?}");
        println!("Input config: {input_config:?}");

        //let output_sample_rate_divider = output_config.sample_rate.0 as usize / 8000;
        let output_sample_rate_divider = 1;
        let output_stream = match supported_output_config.sample_format() {
            SampleFormat::F32 => output_device.build_output_stream(
                &output_config,
                create_write_callback::<_, f32>(write_callback, output_sample_rate_divider),
                |_| {},
                None,
            ),
            SampleFormat::I16 => output_device.build_output_stream(
                &output_config,
                create_write_callback::<_, i16>(write_callback, output_sample_rate_divider),
                |_| {},
                None,
            ),
            SampleFormat::U16 => output_device.build_output_stream(
                &output_config,
                create_write_callback::<_, u16>(write_callback, output_sample_rate_divider),
                |_| {},
                None,
            ),
            _ => panic!(),
        }
        .context("could not create output stream")?;
        output_stream
            .play()
            .context("can not start the output stream")?;

        let in_err = |err| {
            println!("{err:?}");
        };

        //let input_sample_rate_divider = input_config.sample_rate.0 as usize / 8000;
        let input_sample_rate_divider = 1;
        let input_stream = match supported_input_config.sample_format() {
            SampleFormat::F32 => input_device.build_input_stream(
                &input_config,
                create_read_callback::<_, f32>(read_callback, input_sample_rate_divider),
                in_err,
                None,
            ),
            SampleFormat::I16 => input_device.build_input_stream(
                &input_config,
                create_read_callback::<_, i16>(read_callback, input_sample_rate_divider),
                in_err,
                None,
            ),
            SampleFormat::U16 => input_device.build_input_stream(
                &input_config,
                create_read_callback::<_, u16>(read_callback, input_sample_rate_divider),
                in_err,
                None,
            ),
            _ => panic!(),
        }
        .context("could not create input stream")?;
        input_stream
            .play()
            .context("can not start the input stream")?;

        Ok(AudioIo {
            output_stream,
            input_stream,
        })
    }

    pub fn stop(self) {
        self.output_stream.pause().unwrap();
        self.input_stream.pause().unwrap();
    }
}

fn create_write_callback<CB, T>(
    write_callback: CB,
    sample_rate_divider: usize,
) -> impl FnMut(&mut [T], &cpal::OutputCallbackInfo)
where
    CB: Fn(&mut [i16]),
    T: Sample + cpal::FromSample<i16> + cpal::FromSample<f32>,
{
    move |buffer, _info| {
        let mut write_scratch_buff = [0i16; 4096];
        let write_scratch = &mut write_scratch_buff[0..buffer.len() / sample_rate_divider];
        write_callback(write_scratch);
        for (read, write) in write_scratch
            .iter_mut()
            .flat_map(|sample| repeat(*sample).take(sample_rate_divider))
            .zip(buffer.iter_mut())
        {
            *write = T::from_sample(read);
        }
    }
}

fn create_read_callback<CB, T>(
    read_callback: CB,
    sample_rate_divider: usize,
) -> impl FnMut(&[T], &cpal::InputCallbackInfo)
where
    CB: Fn(&[i16]),
    T: Sample,
    f32: FromSample<T>,
{
    move |buffer, _info| {
        let mut read_scratch_buff = [0i16; 4096];
        let read_scratch = &mut read_scratch_buff[0..buffer.len() / sample_rate_divider];
        for (read, write) in buffer
            .iter()
            .enumerate()
            .filter(|(i, _)| *i % sample_rate_divider == 0)
            .map(|(_, sample)| sample)
            .zip(read_scratch.iter_mut())
        {
            *write = i16::from_sample(f32::from_sample(*read));
        }
        read_callback(read_scratch);
    }
}
