use clap::Parser;

#[derive(Parser, Debug, PartialEq, Eq)]
#[command(author, version, about, long_about = None)]
pub struct Cli {
    /// Port of the HTTP server
    #[arg(short = 'p', long, value_name = "HTTP_PORT", default_value = "8080")]
    pub http_port: u16,
    /// Address to listen on (`0.0.0.0`/`::` or `127.0.0.1`/`::1`)
    #[arg(short = 'a', long, value_name = "HTTP_ADDRESS", default_value = "::1")]
    pub http_address: String,
}
