package validatorpolicy

import (
	"context"
	"fmt"
)

// Policy implements the policy engine interface
// It validates that required fields are present in the input
type Policy struct{}

// Name returns the unique identifier for this policy
func (p *Policy) Name() string {
	return "validator-policy"
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
	result["action"] = "field validation"

	// Define required fields
	requiredFields := []string{"message", "data"}

	// Validate presence of required fields
	missingFields := []string{}
	validFields := []string{}

	for _, field := range requiredFields {
		if _, exists := inputMap[field]; exists {
			validFields = append(validFields, field)
		} else {
			missingFields = append(missingFields, field)
		}
	}

	result["required_fields"] = requiredFields
	result["valid_fields"] = validFields
	result["missing_fields"] = missingFields

	if len(missingFields) > 0 {
		result["status"] = "FAILED"
		result["message"] = fmt.Sprintf("Missing required fields: %v", missingFields)
	} else {
		result["status"] = "PASSED"
		result["message"] = "All required fields present"
	}

	return result, nil
}

// Validate checks if the policy configuration is valid
func (p *Policy) Validate() error {
	// This simple policy has no configuration to validate
	return nil
}
