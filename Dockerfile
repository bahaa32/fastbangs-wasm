FROM lukemathwalker/cargo-chef:latest as chef

WORKDIR /build

## Stage 0: Prepare dependency recipe, useful for caching
FROM chef as planner
COPY . .
RUN --mount=type=bind,target=.                              \
        cargo chef prepare --recipe-path /recipe.json

## Stage 1: Build the WebAssembly binary
FROM chef as builder

VOLUME [ "/build/out" ]
COPY --from=planner /recipe.json recipe.json

# Set cargo config to speed up index updates
#  https://github.com/rust-lang/cargo/issues/9167
ARG CARGOCFG="                                            \n\
[source.crates-io]                                        \n\
registry = \"git://github.com/rust-lang/crates.io-index.git\""

# Install apt dependencies and persist apt cache
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked   \
        apt update && apt install zip binaryen -y

RUN rustup target add wasm32-unknown-unknown

# Install wasm-pack and persist cargo cache
RUN --mount=type=cache,target=./target,sharing=locked       \
    --mount=type=cache,target=~/.cargo/registry,sharing=locked \
        mkdir -p ~/.cargo                                && \
        echo "$CARGOCFG" >> ~/.cargo/config              && \
        cargo install wasm-pack wasm-bindgen-cli


# Cook recipe 😋
RUN --mount=type=cache,target=~/.cargo/,sharing=locked      \
        cargo chef cook --target wasm32-unknown-unknown     \
          --check --no-std --release --recipe-path recipe.json

COPY . .

# Run build script
RUN --mount=type=cache,target=./target,sharing=locked       \
    --mount=type=cache,target=~/.cargo/,sharing=locked      \
        ./build.sh

## Stage 2: Export output
FROM scratch as exporter
COPY --from=builder /build/out /
