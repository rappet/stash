use std::path::PathBuf;

use clap::{Parser, Subcommand};

#[derive(Parser, Debug, PartialEq, Eq)]
#[command(author, version, about, long_about)]
pub struct Args {
    #[command(subcommand)]
    pub command: Commands,
}

#[derive(Subcommand, Debug, PartialEq, Eq)]
pub enum Commands {
    Pack {
        source: PathBuf,
        archive: PathBuf,
    },
    Unpack {
        archive: PathBuf,
        destination: PathBuf,
    },
}
