# FastBangs ⚡💥

**FastBangs** is a fast Firefox extension that adds DuckDuckGo's [bangs](https://duckduckgo.com/bangs) functionality to Google search and greatly speeds them up by processing them before requests are made.

## Building 🔨

Before building, make sure you have the `zip` and [`wasm-pack`](https://rustwasm.github.io/wasm-pack/installer/) installed.

Clone this repository and run `build.sh`. The packaged extension will be placed in the `out` folder.

## Performance 🚄💨
The increased responsiveness is definitely observable. On my machine, a query with a bang took ~140ms before it redirected me to the destination. By comparison, FastBangs starts a lookup immediately after you submit your query (and before the request is even made). The lookup is near instant, consistently taking >1 ms from start to redirect on my machine.

For more context, the native Rust `process_query` function takes ~200 nanoseconds to run on my laptop (although the WASM build is likely to be a bit slower). This speed is achieved by pre-building a fast and static `Map` using [`phf`](https://crates.io/crates/phf) before compile time in `build.rs`. This has the benefit of throwing away data we don't need from the original DuckDuckGo bangs list to save space and speeds up execution in runtime (compared to parsing the bangs list's JSON in runtime since it is very large at ~2.5MB).

## Limitations 📋
FastBangs does not work with POST requests. While it is technically possible to support them, that may require modifying the page's Content Security Policy (CSP) which I am not comfortable doing.
