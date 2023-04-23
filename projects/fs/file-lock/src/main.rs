#![deny(clippy::all)]
#![warn(clippy::pedantic)]
#![warn(clippy::nursery)]

mod cli;

use std::{
    fs::{self, File},
    io::Write,
    path::Path,
};

use aead::{AeadCore, AeadInPlace, KeyInit, KeySizeUser, OsRng};
use anyhow::{Context, Result};
use argon2::{Argon2, PasswordHasher};
use chacha20poly1305::ChaCha20Poly1305;
use clap::Parser;

use cli::{Args, Commands};
use file_lock::encoding::outer_header::{Argon2idKeySlot, KeySlot, RootBlock, UpperHeader};

fn main() -> Result<()> {
    let args = Args::parse();

    match args.command {
        Commands::Pack { source, archive } => unpack(&source, &archive),
        _ => unimplemented!("no unpack"),
    }
}

pub fn unpack(source: &Path, archive: &Path) -> Result<()> {
    let password = rpassword::prompt_password("Choose password: ")?;

    let mut source_data = fs::read(source).context("Failed reading source file")?;
    let mut archive_file = File::create(archive).context("Failed creating archive file")?;

    let mut salt = [0u8; 32];
    let mut aead_key = [0u8; 32];

    getrandom::getrandom(&mut salt).unwrap();
    Argon2::default()
        .hash_password_into(password.as_bytes(), &salt, &mut aead_key)
        .unwrap();

    let cipher = ChaCha20Poly1305::new((&aead_key).into());
    let nonce = ChaCha20Poly1305::generate_nonce(&mut OsRng);
    cipher
        .encrypt_in_place(&nonce, b"", &mut source_data)
        .unwrap();

    let root_block = RootBlock {
        upper_header: UpperHeader {
            key_slots: vec![KeySlot::Argon2id(Argon2idKeySlot {
                salt: salt.to_vec(),
            })],
        },
        root_data: source_data,
    };

    root_block.write(&mut archive_file)?;

    archive_file.flush()?;

    Ok(())
}
