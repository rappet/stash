use anyhow::Result;
use clap::Parser;

use rust_cli_template::cli::Cli;

fn main() -> Result<()> {
    //env_logger::init();
    let args = Cli::parse();

    println!("Hello, {}!", args.name);

    Ok(())
}
