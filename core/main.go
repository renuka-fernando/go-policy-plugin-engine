package main

import (
	"context"
	"encoding/json"
	"log"
	"os"
)

var registry = NewPolicyRegistry()

// RegisterPolicy is called by the generated imports.go to register policies
func RegisterPolicy(p Policy) {
	if err := registry.Register(p); err != nil {
		log.Fatalf("Failed to register policy %s: %v", p.Name(), err)
	}
	log.Printf("Registered policy: %s", p.Name())
}

func main() {
	log.Println("Policy Engine Starting...")

	// List all registered policies
	policies := registry.List()
	log.Printf("Loaded %d policies: %v", len(policies), policies)

	if len(policies) == 0 {
		log.Println("Warning: No policies registered")
		return
	}

	// Example: Execute all policies with sample input
	ctx := context.Background()
	input := map[string]interface{}{
		"message": "Hello from policy engine",
		"data":    []string{"item1", "item2", "item3"},
	}

	log.Println("\nExecuting policies...")
	for _, name := range policies {
		policy, _ := registry.Get(name)
		log.Printf("\n--- Executing policy: %s ---", name)

		result, err := policy.Execute(ctx, input)
		if err != nil {
			log.Printf("Error executing policy %s: %v", name, err)
			continue
		}

		// Pretty print the result
		resultJSON, _ := json.MarshalIndent(result, "", "  ")
		log.Printf("Result: %s", string(resultJSON))
	}

	log.Println("\nPolicy Engine Completed Successfully")
}

func init() {
	// Configure logging
	log.SetOutput(os.Stdout)
	log.SetFlags(log.Ldate | log.Ltime | log.Lshortfile)
}
