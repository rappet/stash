include!("src/cli.rs");

use clap::CommandFactory;

fn main() -> std::io::Result<()> {
    let cmd = Cli::command();

    let man = clap_mangen::Man::new(cmd);
    let mut buffer: Vec<u8> = Default::default();
    man.render(&mut buffer)?;

    let crate_name = std::env::var("CARGO_PKG_NAME").unwrap();

    std::fs::write(format!("man/{crate_name}.1"), buffer)?;

    Ok(())
}
