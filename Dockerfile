# Start with a Rust image that already has the toolchain
FROM rust:slim

WORKDIR /app

# Install build dependencies first
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    pkg-config \
    libssl-dev \
    libsqlite3-dev \
    libpq-dev \
    ca-certificates \
    build-essential \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy only the files needed for dependency resolution first
COPY Cargo.toml Cargo.lock ./
# If you have a build.rs file, copy it too
COPY build.rs ./

# Create a dummy src/main.rs to trigger dependency compilation
RUN mkdir -p src && \
    echo "fn main() {}" > src/main.rs && \
    cargo build --release && \
    rm -rf src target/release/deps/covclaim*

# Now copy the real source code
COPY . .

# Build the application with verbose output
RUN RUST_BACKTRACE=1 cargo build --release -v

# Configure the application
EXPOSE 1234

# Set API_HOST to listen on all available interfaces
ENV API_HOST=0.0.0.0

# Run the application
CMD ["./target/release/covclaim"]