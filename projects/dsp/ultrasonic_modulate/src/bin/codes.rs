const BITS: usize = 1 << 10;
const BITS_SET: u32 = 5;

fn main() {
    let codes: Vec<_> = (0..BITS).filter(|v| v.count_ones() == BITS_SET).collect();

    let mut filtered = Vec::new();
    for (i, &code) in codes.iter().enumerate() {
        if !codes[0..i].iter().any(|&c2| (c2 ^ code).count_ones() < 2) {
            filtered.push(code);
        }
    }

    for code in &filtered {
        println!("{code:05b}");
    }
    println!("{} {}", codes.len(), filtered.len());
}
