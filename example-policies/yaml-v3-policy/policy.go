package yamlv3policy

import (
	"context"
	"fmt"

	"gopkg.in/yaml.v3"
)

// Policy implements the policy engine interface using YAML v3
type Policy struct{}

// Name returns the unique identifier for this policy
func (p *Policy) Name() string {
	return "yaml-v3-policy"
}

// Execute runs the policy logic using yaml.v3
func (p *Policy) Execute(ctx context.Context, input interface{}) (interface{}, error) {
	// Convert input to map
	inputMap, ok := input.(map[string]interface{})
	if !ok {
		return nil, fmt.Errorf("expected map[string]interface{}, got %T", input)
	}

	result := make(map[string]interface{})
	result["policy"] = p.Name()
	result["action"] = "yaml v3 parsing"
	result["library"] = "gopkg.in/yaml.v3"

	// Marshal and unmarshal using yaml.v3 to demonstrate library usage
	yamlData, err := yaml.Marshal(inputMap)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal with yaml.v3: %w", err)
	}

	var parsed map[string]interface{}
	err = yaml.Unmarshal(yamlData, &parsed)
	if err != nil {
		return nil, fmt.Errorf("failed to unmarshal with yaml.v3: %w", err)
	}

	result["input"] = inputMap
	result["yaml_output"] = string(yamlData)
	result["parsed"] = parsed

	return result, nil
}

// Validate checks if the policy configuration is valid
func (p *Policy) Validate() error {
	return nil
}
