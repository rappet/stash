use clap::Parser;

#[derive(Parser, Debug, PartialEq, Eq)]
#[command(author, version, about, long_about = None)]
pub struct Cli {
    /// The name of the user
    #[arg(short, long, value_name = "NAME", default_value = "World")]
    pub name: String,
}
