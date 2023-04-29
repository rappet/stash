use std::{iter::repeat, time::Instant};

use aead::{AeadCore, AeadInPlace, KeyInit, OsRng};
use aes_gcm::{Aes128Gcm, Aes256Gcm};
use aes_gcm_siv::{Aes128GcmSiv, Aes256GcmSiv};
use aes_siv::{Aes128SivAead, Aes256SivAead};
use argh::FromArgs;
use chacha20poly1305::{ChaCha20Poly1305, XChaCha20Poly1305};
use xsalsa20poly1305::XSalsa20Poly1305;

#[derive(Debug, Clone, Copy, FromArgs)]
/// Simple benchmarker for Rust AEAD implementations
struct BenchSettings {
    /// count of rounds to test
    #[argh(option, short = 'r', default = "4096")]
    pub rounds: u32,

    /// buffer size for one iteration
    #[argh(option, short = 's', default = "4096")]
    pub buffer_size: usize,
}

fn bench<C: AeadCore + AeadInPlace + KeyInit + 'static>(name: &str, settings: BenchSettings) {
    let key = C::generate_key(&mut OsRng);
    let cipher = C::new(&key);
    let nonce = C::generate_nonce(&mut OsRng);

    let start = Instant::now();
    for _i in 0..settings.rounds {
        let cleartext_size = settings.buffer_size;
        let mut buffer = Vec::with_capacity(cleartext_size + 256);
        buffer.extend(repeat(0u8).take(cleartext_size));
        cipher.encrypt_in_place(&nonce, b"", &mut buffer).unwrap();
    }
    let time_taken = Instant::now().duration_since(start);
    let time_per_round = time_taken / settings.rounds;
    println!(
        "| {name:20} | {:8} | {time_taken:15?} | {time_per_round:15?} |",
        key.len() * 8,
    );
}

fn main() {
    let settings: BenchSettings = argh::from_env();

    println!(
        "Benchmarking with {:5} rounds of a {:5} bytes large buffer",
        settings.rounds, settings.buffer_size
    );
    println!("------------------------------------------------------------");
    println!();

    println!("| cipher               | key size | time            | time per round  |");
    println!("| -------------------- | -------- | --------------- | --------------- |");
    bench::<ChaCha20Poly1305>("ChaCha20Poly1305", settings);
    bench::<XChaCha20Poly1305>("XChaCha20Poly1305", settings);
    bench::<XSalsa20Poly1305>("XSalsa20Poly1305", settings);
    bench::<Aes128Gcm>("AES GCM", settings);
    bench::<Aes256Gcm>("AES GCM", settings);
    bench::<Aes128SivAead>("AES SIV", settings);
    bench::<Aes256SivAead>("AES SIV", settings);
    bench::<Aes128GcmSiv>("AES GCM SIV", settings);
    bench::<Aes256GcmSiv>("AES GCM SIV", settings);

    println!("\n");
}
