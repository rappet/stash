# A simple benchmark tool for Rust AEAD ciphers

## Example

Running on an `AMD Ryzen 7 3700X (16) @ 3.800GHz`:


Benchmarking with  4096 rounds of a  4096 bytes large buffer
------------------------------------------------------

| cipher | key size | time | time per round |
| ------ | -------- | ---- | -------------- |
| chacha20poly1305::ChaChaPoly1305         | 256 | 23.738781ms     | 5.795µs         |
| chacha20poly1305::ChaChaPoly1305         | 256 | 24.04744ms      | 5.87µs          |
| xsalsa20poly1305::XSalsa20Poly1305       | 256 | 42.447066ms     | 10.363µs        |
| aes_gcm::AesGcm                          | 128 | 19.207065ms     | 4.689µs         |
| aes_gcm::AesGcm                          | 256 | 19.938472ms     | 4.867µs         |
| aes_siv::SivAead                         | 256 | 32.572045ms     | 7.952µs         |
| aes_siv::SivAead                         | 512 | 38.329329ms     | 9.357µs         |
| aes_gcm_siv::AesGcmSiv                   | 128 | 16.557422ms     | 4.042µs         |
| aes_gcm_siv::AesGcmSiv                   | 256 | 17.675508ms     | 4.315µs         |


Benchmarking with  4096 rounds of a    16 bytes large buffer
------------------------------------------------------

| cipher | key size | time | time per round |
| ------ | -------- | ---- | -------------- |
| chacha20poly1305::ChaChaPoly1305         | 256 | 5.869653ms      | 1.433µs         |
| chacha20poly1305::ChaChaPoly1305         | 256 | 6.335781ms      | 1.546µs         |
| xsalsa20poly1305::XSalsa20Poly1305       | 256 | 5.285265ms      | 1.29µs          |
| aes_gcm::AesGcm                          | 128 | 513.849µs       | 125ns           |
| aes_gcm::AesGcm                          | 256 | 549.048µs       | 134ns           |
| aes_siv::SivAead                         | 256 | 1.079927ms      | 263ns           |
| aes_siv::SivAead                         | 512 | 1.773735ms      | 433ns           |
| aes_gcm_siv::AesGcmSiv                   | 128 | 945.297µs       | 230ns           |
| aes_gcm_siv::AesGcmSiv                   | 256 | 1.512685ms      | 369ns           |


Benchmarking with  4096 rounds of a   128 bytes large buffer
------------------------------------------------------

| cipher | key size | time | time per round |
| ------ | -------- | ---- | -------------- |
| chacha20poly1305::ChaChaPoly1305         | 256 | 8.494005ms      | 2.073µs         |
| chacha20poly1305::ChaChaPoly1305         | 256 | 8.855074ms      | 2.161µs         |
| xsalsa20poly1305::XSalsa20Poly1305       | 256 | 8.213947ms      | 2.005µs         |
| aes_gcm::AesGcm                          | 128 | 933.098µs       | 227ns           |
| aes_gcm::AesGcm                          | 256 | 981.647µs       | 239ns           |
| aes_siv::SivAead                         | 256 | 1.941974ms      | 474ns           |
| aes_siv::SivAead                         | 512 | 2.878532ms      | 702ns           |
| aes_gcm_siv::AesGcmSiv                   | 128 | 1.312266ms      | 320ns           |
| aes_gcm_siv::AesGcmSiv                   | 256 | 1.894185ms      | 462ns           |


Benchmarking with  4096 rounds of a 100000 bytes large buffer
------------------------------------------------------

| cipher | key size | time | time per round |
| ------ | -------- | ---- | -------------- |
| chacha20poly1305::ChaChaPoly1305         | 256 | 410.998895ms    | 100.341µs       |
| chacha20poly1305::ChaChaPoly1305         | 256 | 411.460304ms    | 100.454µs       |
| xsalsa20poly1305::XSalsa20Poly1305       | 256 | 869.604411ms    | 212.305µs       |
| aes_gcm::AesGcm                          | 128 | 460.125772ms    | 112.335µs       |
| aes_gcm::AesGcm                          | 256 | 475.335097ms    | 116.048µs       |
| aes_siv::SivAead                         | 256 | 769.738632ms    | 187.924µs       |
| aes_siv::SivAead                         | 512 | 891.753757ms    | 217.713µs       |
| aes_gcm_siv::AesGcmSiv                   | 128 | 381.53234ms     | 93.147µs        |
| aes_gcm_siv::AesGcmSiv                   | 256 | 397.345935ms    | 97.008µs        |


