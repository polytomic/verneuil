FROM lukemathwalker/cargo-chef:latest-rust-alpine3.18 AS chef
WORKDIR app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder 
ENV RUSTFLAGS="-C target-feature=-crt-static"

RUN apk add --no-cache musl-dev sqlite-dev

COPY --from=planner /app/recipe.json recipe.json
# Build dependencies - this is the caching Docker layer!
RUN cargo chef cook --release --recipe-path recipe.json
# Build application
COPY . .
RUN cargo build --release --examples --features='dynamic_vfs'


