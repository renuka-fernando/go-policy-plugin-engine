package uppercasepolicy

import (
	"context"
	"fmt"
	"strings"
)

// Policy implements the policy engine interface
// It converts all string values in the input to uppercase
type Policy struct{}

// Name returns the unique identifier for this policy
func (p *Policy) Name() string {
	return "uppercase-policy"
}

// Execute runs the policy logic
func (p *Policy) Execute(ctx context.Context, input interface{}) (interface{}, error) {
	// Convert input to map
	inputMap, ok := input.(map[string]interface{})
	if !ok {
		return nil, fmt.Errorf("expected map[string]interface{}, got %T", input)
	}

	result := make(map[string]interface{})
	result["policy"] = p.Name()
	result["action"] = "uppercase transformation"

	// Process all string values
	transformed := make(map[string]interface{})
	for key, value := range inputMap {
		switch v := value.(type) {
		case string:
			transformed[key] = strings.ToUpper(v)
		case []string:
			upper := make([]string, len(v))
			for i, s := range v {
				upper[i] = strings.ToUpper(s)
			}
			transformed[key] = upper
		default:
			transformed[key] = v
		}
	}

	result["input"] = inputMap
	result["output"] = transformed

	return result, nil
}

// Validate checks if the policy configuration is valid
func (p *Policy) Validate() error {
	// This simple policy has no configuration to validate
	return nil
}
