# Use a single-stage build to reduce complexity
FROM rust:slim

WORKDIR /app

COPY . .

# Install only required dependencies without upgrade
RUN apt-get update && \
    apt-get install -y --no-install-recommends libsqlite3-0 libpq5 ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Build the application
RUN cargo build --release

# Configure the application
EXPOSE 1234

# Run the application
CMD ["./target/release/covclaim"]