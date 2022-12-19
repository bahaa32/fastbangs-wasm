# FastBangs ⚡💥

**FastBangs** is a fast Firefox extension that adds DuckDuckGo's [bangs](https://duckduckgo.com/bangs) functionality to Google search and greatly speeds them up by using WebAssembly and processing bangs before requests are made.

## Building 🔨
First, clone this repository.

There are two ways to build the extension:
- 🐳 via Docker: run `./build.sh docker` (requires [Docker](https://docs.docker.com/get-docker/))
- 💻 Locally: run `./build.sh` (requires [`Rust`](https://www.rust-lang.org/tools/install), [`wasm-pack`](https://rustwasm.github.io/wasm-pack/installer/#), [`zip`](https://www.tecmint.com/install-zip-and-unzip-in-linux/))

The output will be placed in the `out` folder. You can remove this folder if you wish by running `./build.sh clean`

## Performance 🚄💨
The increased responsiveness is definitely observable. On my machine, a query (on DuckDuckGo) with a bang took ~140ms before it redirected me to the destination. By comparison, FastBangs starts a lookup immediately after you submit your query (and before the request is even made). The lookup is near instant, consistently taking **>1 ms** from start to redirect on my machine.

For more context, the native Rust `process_query` function takes **~200 nanoseconds** to run on my laptop (although the WASM build is likely to be a bit slower). This speed is achieved by pre-building a fast and static `Map` using [`phf`](https://crates.io/crates/phf) before compile time in `build.rs`. This has the benefit of throwing away data we don't need from the original DuckDuckGo bangs list to save space and speeds up execution in runtime (compared to parsing the bangs list's JSON in runtime since it is very large at ~2.5MB).

The resulting Rust code (including the generated map) is then compiled to WebAssembly and embedded into the extension to achieve this level of performance.

## Limitations 📋
FastBangs does not work with POST requests. While it is technically possible to support them, that may require modifying the page's Content Security Policy (CSP) which I am not comfortable doing.
