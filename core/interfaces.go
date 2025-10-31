package main

import (
	"context"
)

// Policy defines the interface that all policy plugins must implement
type Policy interface {
	// Name returns the unique identifier for this policy
	Name() string

	// Execute runs the policy logic with the given input
	Execute(ctx context.Context, input interface{}) (interface{}, error)

	// Validate checks if the policy configuration is valid
	Validate() error
}

// PolicyRegistry manages all registered policies
type PolicyRegistry struct {
	policies map[string]Policy
}

// NewPolicyRegistry creates a new policy registry
func NewPolicyRegistry() *PolicyRegistry {
	return &PolicyRegistry{
		policies: make(map[string]Policy),
	}
}

// Register adds a policy to the registry
func (r *PolicyRegistry) Register(p Policy) error {
	if err := p.Validate(); err != nil {
		return err
	}
	r.policies[p.Name()] = p
	return nil
}

// Get retrieves a policy by name
func (r *PolicyRegistry) Get(name string) (Policy, bool) {
	p, ok := r.policies[name]
	return p, ok
}

// List returns all registered policy names
func (r *PolicyRegistry) List() []string {
	names := make([]string, 0, len(r.policies))
	for name := range r.policies {
		names = append(names, name)
	}
	return names
}
