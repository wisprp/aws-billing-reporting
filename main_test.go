package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
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

func TestSendSlackNotification(t *testing.T) {
	const message = "test"
	const expectedContentType = "application/json"

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		contentType := r.Header.Get("Content-Type")
		if contentType != expectedContentType {
			t.Errorf("expected content type header %s but was %s", expectedContentType, contentType)
		}

		if r.Method == http.MethodPost {
			_, err := w.Write([]byte("ok"))
			if err != nil {
				t.Error(err)
			}
			return
		}

		var slackReq SlackRequestBody
		if err := json.NewDecoder(r.Body).Decode(&slackReq); err != nil {
			t.Error(err)
		}

		if slackReq.Text != message {
			t.Errorf("expected message '%s' but was '%s'", message, slackReq.Text)
		}

		w.WriteHeader(http.StatusMethodNotAllowed)
	}))

	defer srv.Close()

	err := SendSlackNotification(srv.URL, message)
	if err != nil {
		t.Error(err)
	}

}

func TestSendSlackNotificationFailOnUnexpectedResponse(t *testing.T) {
	const message = "test"

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_, err := w.Write([]byte(""))
		if err != nil {
			t.Error(err)
		}
	}))

	defer srv.Close()

	err := SendSlackNotification(srv.URL, message)
	if err == nil {
		t.Error("an error was expected")
	}

}

func TestSendSlackNotificationFailOnUnexpectedStatusCode(t *testing.T) {
	const message = "test"

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusInternalServerError)
	}))

	defer srv.Close()

	err := SendSlackNotification(srv.URL, message)
	if err == nil {
		t.Error("an error was expected")
	}

}
