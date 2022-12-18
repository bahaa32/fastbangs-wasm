use std::env;
use std::fs::File;
use std::io::{BufWriter, Write};
use std::path::Path;
use reqwest;
use serde::{Deserialize};

// Struct to deserialize bangs from duckduckgo
#[derive(Deserialize)]
struct Bang {
    t: String,
    u: String,
}

fn main() {
    let path = Path::new(&env::var("OUT_DIR").unwrap()).join("codegen.rs");
    let mut file = BufWriter::new(File::create(&path).unwrap());

    // Get bangs from duckduckgo every time the project is built and generate a smaller static map
    let bangs_list: Vec<Bang> = match reqwest::blocking::get("https://duckduckgo.com/bang.js").unwrap().json() {
            Ok(bangs) => bangs,
            Err(e) => panic!("Error: {}", e),
        };
    let mut bangs_map = phf_codegen::Map::new();

    for bang in bangs_list {
        bangs_map.entry(bang.t.clone(), format!("r#\"{}\"#", bang.u).as_str());
    }

    // Write the map to codegen.rs
    write!(
        &mut file,
        "static BANGS: phf::Map<&'static str, &'static str> = {}",
        bangs_map.build()
    )
    .unwrap();
    write!(&mut file, ";\n").unwrap();
}
