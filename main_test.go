package main

import (
	"os"
	"testing"
)

// IsIgnored func
func TestIsIgnored(t *testing.T) {
	os.Setenv("BILLING_IGNORE_LIST", "lorem,ipsum,project3,bar")
	testProject := "Billing$foo"
	if isIgnored(&testProject) {
		t.Errorf("Project %s is IGNORED but it shouldn't", testProject)
	}
	testProject = "Billing$lorem,"
	if isIgnored(&testProject) {
		t.Errorf("Project %s is IGNORED but it shouldn't", testProject)
	}
	testProject = "Billing$project3"
	if !isIgnored(&testProject) {
		t.Errorf("Project %s is ACCEPTED but it shouldn't", testProject)
	}

	os.Setenv("BILLING_IGNORE_LIST", "")
	testProject = "Billing$bar"
	if isIgnored(&testProject) {
		t.Errorf("Project %s is IGNORED but it shouldn't", testProject)
	}
	testProject = "Billing$"
	if !isIgnored(&testProject) {
		t.Errorf("Project %s is ACCEPTED but it shouldn't", testProject)
	}
}
