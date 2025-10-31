.PHONY: build test run clean help

# Default target
help:
	@echo "Policy Engine - Available Commands:"
	@echo ""
	@echo "  make build        - Build the policy-builder Docker image"
	@echo "  make test         - Run tests with example policies"
	@echo "  make run          - Run with example policies (interactive)"
	@echo "  make clean        - Clean up Docker images"
	@echo "  make show-imports - Show generated imports file"
	@echo "  make help         - Show this help message"
	@echo ""

# Build the Docker image
build:
	@echo "Building policy-builder image..."
	docker build -t policy-builder:latest .

# Test with example policies
build-engine: build
	@echo "Testing with example policies..."
	docker run --rm \
		-v "$$(pwd)/example-policies:/policies" \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-e POLICY_ENGINE_IMAGE_REPO=policy-engine \
		policy-builder:latest
	docker run policy-engine:latest

# Test with example policies
test: build-engine
	docker run policy-engine:latest

# Run without building (assumes image exists)
run:
	@echo "Running with example policies..."
	docker run --rm \
		-v "$$(pwd)/example-policies:/policies" \
		policy-builder:latest

# Show the generated imports.go file
show-imports:
	@echo "Generating and displaying imports.go..."
	@docker run --rm \
		-v "$$(pwd)/example-policies:/policies" \
		--entrypoint sh \
		policy-builder:latest \
		-c "/build.sh > /dev/null 2>&1 && cat /app/core/imports.go"

# Clean up
clean:
	@echo "Cleaning up Docker images..."
	docker rmi policy-builder:latest || true
	@echo "Done!"

# Build only (no run)
build-only:
	@echo "Building binary only..."
	docker run --rm \
		-v "$$(pwd)/example-policies:/policies" \
		-v "$$(pwd)/output:/output" \
		--entrypoint sh \
		policy-builder:latest \
		-c "/build.sh && cp /app/core/policy-engine /output/"
	@echo "Binary saved to ./output/policy-engine"
