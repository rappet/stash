use smallvec::SmallVec;
use std::time::Instant;
use tinyvec::{ArrayVec, TinyVec};

static S: &str = "Hello,World,foo,bar,buzz,tuzz,buzz,ruzz,puzz!";

fn bench(f: impl Fn(usize, &str) -> usize, s: &str) {
    let start = Instant::now();
    let mut sum = 0;
    for i in 0..1000000 {
        sum += f(i, s);
    }
    println!("Duration: {:?}, sum: {}", start.elapsed(), sum);
}

fn with_vec(_i: usize, s: &str) -> usize {
    let mut v = s.split(',').map(str::trim).collect::<Vec<_>>();
    v.sort_unstable();
    v[0].len()
}

fn with_tinyvec(_i: usize, s: &str) -> usize {
    let mut v = s.split(',').map(str::trim).collect::<TinyVec<[_; 64]>>();
    v.sort_unstable();
    v[0].len()
}

fn with_smallvec(_i: usize, s: &str) -> usize {
    let mut v = s.split(',').map(str::trim).collect::<SmallVec<[_; 64]>>();
    v.sort_unstable();
    v[0].len()
}

fn with_arrayvec(_i: usize, s: &str) -> usize {
    let mut v = s.split(',').map(str::trim).collect::<ArrayVec<[_; 64]>>();
    v.sort_unstable();
    v[0].len()
}

fn do_benches(s: &str) {
    print!("Vec:      ");
    bench(with_vec, s);
    print!("TinyVec:  ");
    bench(with_tinyvec, s);
    print!("SmallVec: ");
    bench(with_smallvec, s);
    print!("ArrayVec: ");
    bench(with_arrayvec, s);
    println!("---------");
}

fn main() {
    for _ in 0..5 {
        do_benches(S);
    }
}
