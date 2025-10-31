# Quick Start Guide

Get up and running with the Policy Engine in 5 minutes!

## Prerequisites

- Docker installed and running
- Basic knowledge of Go

## Step 1: Test the System (1 minute)

```bash
# Run the test
make test
```

You should see output showing:
- 2 policies discovered
- Binary built (2.2MB)
- Policies executed successfully

## Step 2: Create Your First Policy (2 minutes)

Create a new directory for your policy:

```bash
mkdir -p my-policies/hello-world
cd my-policies/hello-world
```

Create `go.mod`:

```go
module github.com/myorg/policies/hello-world

go 1.21
```

Create `policy.go`:

```go
package helloworld

import "context"

type Policy struct{}

func (p *Policy) Name() string {
    return "hello-world"
}

func (p *Policy) Execute(ctx context.Context, input interface{}) (interface{}, error) {
    return map[string]interface{}{
        "policy":  p.Name(),
        "message": "Hello from my first policy!",
        "input":   input,
    }, nil
}

func (p *Policy) Validate() error {
    return nil
}
```

## Step 3: Run Your Policy (1 minute)

```bash
cd ../..  # Back to project root

# Run with your policy
docker run --rm \
  -v $(pwd)/my-policies:/policies \
  policy-builder:latest run
```

## Step 4: View Generated Code (30 seconds)

See what the system generated:

```bash
docker run --rm \
  -v $(pwd)/my-policies:/policies \
  --entrypoint sh \
  policy-builder:latest \
  -c "/build.sh > /dev/null 2>&1 && cat /app/core/imports.go"
```

You'll see your policy was automatically imported and registered!

## What Just Happened?

1. **Import Generator** scanned `/policies` and found your `hello-world` module
2. **Code Generator** created `imports.go` with your policy imported
3. **Build System** resolved dependencies and compiled everything
4. **Runtime** loaded and executed your policy

## Next Steps

### Try Multiple Policies

Create another policy in `my-policies/another-policy/` and run again. The system will automatically discover and include both!

### Customize the Core

Modify `core/main.go` to change how policies are executed:
- Add command-line arguments
- Read input from files
- Add metrics/logging
- Change output format

### Use in Production

Extract the binary:

```bash
docker run --rm \
  -v $(pwd)/my-policies:/policies \
  -v $(pwd)/output:/output \
  --entrypoint sh \
  policy-builder:latest \
  -c "/build.sh && cp /app/core/policy-engine /output/"

# Now you have a standalone binary!
./output/policy-engine
```

## Common Commands

```bash
make test          # Test with example policies
make build         # Build the Docker image
make run           # Run with example policies
make show-imports  # View generated code
make help          # Show all commands
```

## Policy Interface Reference

Every policy must implement these three methods:

```go
type Policy interface {
    Name() string                                                    // Unique identifier
    Execute(ctx context.Context, input interface{}) (interface{}, error)  // Main logic
    Validate() error                                                // Validate config
}
```

## Tips

1. **Naming Convention**: Name your main file `policy.go` and main type `Policy`
2. **Package Name**: Use lowercase, no dashes (e.g., `helloworld`, not `hello-world`)
3. **Module Path**: Use a valid Go module path in `go.mod`
4. **Testing**: Test your policy independently before integrating

## Troubleshooting

**Policy not discovered?**
- Ensure `go.mod` exists in policy directory
- Check file is named `policy.go`
- Verify type is named `Policy`

**Build fails?**
- Check your policy implements all interface methods
- Verify no syntax errors in your policy code
- Make sure module path in go.mod is valid

**Import errors?**
- Use `make show-imports` to see generated code
- Check for typos in package name

## Example Policies

Check `example-policies/` for complete examples:
- **uppercase-policy** - String transformation
- **validator-policy** - Input validation

## Full Documentation

See `README.md` for complete documentation including:
- Architecture details
- Advanced usage
- Security considerations
- Performance tuning
- Extension points

## Questions?

- Read `README.md` for detailed documentation
- Check `plan.md` for architecture decisions
- View `SUMMARY.md` for implementation overview

Happy policy building! 🚀
