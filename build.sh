#!/bin/sh
# Build script for Policy Engine
# This script orchestrates the build process:
# 1. Runs import generator to discover and register policies
# 2. Resolves dependencies
# 3. Builds the final application binary
# 4. Creates a final Alpine-based Docker image

set -e

echo "========================================="
echo "Policy Engine Build Process"
echo "========================================="

# Step 1: Run import generator
echo ""
echo "Step 1: Running import generator..."
cd /app/import-generator

# Download dependencies for import generator
echo "  - Downloading import generator dependencies..."
go mod download

# Run the import generator
echo "  - Scanning policies in /policies..."
go run main.go -policies=/policies -output=/app/core/imports.go

echo "  ✓ Import generation complete"

# Step 2: Resolve dependencies
echo ""
echo "Step 2: Resolving dependencies..."
cd /app/core

# If there are policies, we need to add them as dependencies
if [ -d "/policies" ]; then
    echo "  - Adding policy modules to go.mod..."

    # For each policy directory, add as a replace directive
    for policy_dir in /policies/*/; do
        if [ -f "${policy_dir}go.mod" ]; then
            policy_name=$(basename "$policy_dir")
            # Extract module path from go.mod
            module_path=$(grep "^module " "${policy_dir}go.mod" | awk '{print $2}')
            if [ -n "$module_path" ]; then
                echo "    Adding: $module_path -> $policy_dir"
                go mod edit -replace="$module_path=$policy_dir"
            fi
        fi
    done
fi

# Tidy up dependencies
echo "  - Running go mod tidy..."
go mod tidy

echo "  ✓ Dependencies resolved"

# Step 3: Build the application
echo ""
echo "Step 3: Building application..."
echo "  - Compiling Go binary..."
CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o policy-engine .

echo "  ✓ Build complete"

# Step 4: Show binary summary
echo ""
echo "========================================="
echo "Build Summary"
echo "========================================="
echo "Binary: /app/core/policy-engine"
echo "Size: $(du -h /app/core/policy-engine | cut -f1)"

# Step 5: Create final Docker image
echo ""
echo "Step 4: Creating final Docker image..."

# Check if Docker socket is mounted
if [ ! -S /var/run/docker.sock ]; then
    echo "  ⚠ Warning: Docker socket not mounted at /var/run/docker.sock"
    echo "  Skipping Docker image creation."
    echo "  To create final image, mount Docker socket:"
    echo "  docker run -v /var/run/docker.sock:/var/run/docker.sock ..."
    echo ""
    echo "Binary available at: /app/core/policy-engine"
    echo "========================================="
    exit 0
fi

# Create temporary directory for Docker build context
BUILD_CONTEXT="/tmp/final-image-build"
mkdir -p "$BUILD_CONTEXT"

# Copy the binary to build context
echo "  - Preparing build context..."
cp /app/core/policy-engine "$BUILD_CONTEXT/"

# Create a Dockerfile for the final image
cat > "$BUILD_CONTEXT/Dockerfile" << 'EOF'
FROM alpine:latest

# Add ca-certificates for HTTPS support
RUN apk --no-cache add ca-certificates

# Create non-root user
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

WORKDIR /app

# Copy the binary
COPY policy-engine /app/policy-engine

# Make binary executable
RUN chmod +x /app/policy-engine

# Switch to non-root user
USER appuser

# Set entrypoint
ENTRYPOINT ["/app/policy-engine"]
EOF

# Build the final Docker image
echo "  - Building final Docker image..."
IMAGE_NAME="${POLICY_ENGINE_IMAGE_REPO:-policy-engine}"
IMAGE_TAG="${POLICY_ENGINE_TAG:-latest}"

docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" "$BUILD_CONTEXT"

echo "  ✓ Final image created: ${IMAGE_NAME}:${IMAGE_TAG}"

# Clean up build context
rm -rf "$BUILD_CONTEXT"

echo ""
echo "========================================="
echo "Final Image Summary"
echo "========================================="
echo "Image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "Base: alpine:latest"
echo ""
echo "To run the final image:"
echo "  docker run ${IMAGE_NAME}:${IMAGE_TAG}"
echo ""
echo "To save the image:"
echo "  docker save ${IMAGE_NAME}:${IMAGE_TAG} -o policy-engine.tar"
echo "========================================="
