use criterion::{black_box, criterion_group, criterion_main, Criterion};
#[path = "../src/lib.rs"]
mod fastbangs_wasm;
use crate::fastbangs_wasm::process_query;

fn criterion_benchmark(c: &mut Criterion) {
    c.bench_function("fib 20", |b| b.iter(|| process_query(black_box("!g test"))));
}

criterion_group!(benches, criterion_benchmark);
criterion_main!(benches);