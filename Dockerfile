# Dockerfile for Policy Engine Builder
# This image contains the core source code and import generator
# Users mount their policies and the image builds the final application

FROM golang:1.21-alpine

# Install build dependencies
RUN apk add --no-cache git docker-cli

# Create working directory
WORKDIR /app

# Copy core application source
COPY core/ /app/core/

# Copy import generator source
COPY import-generator/ /app/import-generator/

# Pre-download import generator dependencies
WORKDIR /app/import-generator
RUN go mod download && go mod verify

# Copy build script
WORKDIR /app
COPY build.sh /build.sh
RUN chmod +x /build.sh

# The build script will:
# 1. Run import generator to scan /policies (mounted by user)
# 2. Generate imports.go
# 3. Build the final application binary
# 4. Optionally run it if "run" argument is passed
ENTRYPOINT ["/build.sh"]
