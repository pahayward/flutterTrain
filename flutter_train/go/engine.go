// Package goengine exposes a yaegi-based Go runner for the flutterTrain app.
// Bound to Android via `gomobile bind`; the generated Java class is
// com.fluttertrain.goengine.Goengine with static methods ping() and run(...).
package goengine

import (
	"bytes"
	"regexp"
	"strings"
	"time"

	"github.com/traefik/yaegi/interp"
	"github.com/traefik/yaegi/stdlib"
)

// Ping is a smoke test used by the app's engine health check.
func Ping() string {
	return "pong"
}

var (
	importSingle  = regexp.MustCompile(`(?m)^import\s+"([^"]+)"`)
	importBlockML = regexp.MustCompile(`(?ms)^import\s+\(\n(.*?)\n\)`)
	importBlockOL = regexp.MustCompile(`(?m)^import\s+\((.*?)\)`)
	lineImport    = regexp.MustCompile(`\s*"([^"]+)"`)
)

// hoistImports pulls import statements out of the user body (Go forbids
// imports inside func bodies) and returns package-level imports + the body.
func hoistImports(code string) (imps string, body string) {
	saw := map[string]bool{}
	var list []string
	add := func(p string) {
		if !saw[p] {
			saw[p] = true
			list = append(list, p)
		}
	}

	if m := importBlockML.FindStringSubmatch(code); m != nil {
		for _, l := range lineImport.FindAllStringSubmatch(m[1], -1) {
			add(l[1])
		}
		code = strings.Replace(code, m[0], "", 1)
	}
	if m := importBlockOL.FindStringSubmatch(code); m != nil {
		for _, l := range lineImport.FindAllStringSubmatch(m[1], -1) {
			add(l[1])
		}
		code = strings.Replace(code, m[0], "", 1)
	}
	for _, m := range importSingle.FindAllStringSubmatch(code, -1) {
		add(m[1])
		code = strings.Replace(code, m[0], "", 1)
	}
	if len(list) > 0 {
		q := make([]string, len(list))
		for i, p := range list {
			q[i] = "\t\"" + p + "\""
		}
		imps = "import (\n" + strings.Join(q, "\n") + "\n)\n\n"
	}
	return imps, code
}

// Run evaluates a Go source snippet and returns captured stdout (plus any
// error text). A fresh interpreter is created per run so state never leaks
// between executions. timeoutMs caps wall-clock time; 0 uses the default.
func Run(code string, timeoutMs float64) string {
	timeout := time.Duration(timeoutMs) * time.Millisecond
	if timeout <= 0 {
		timeout = 5 * time.Second
	}

	type outcome struct {
		out string
		err error
	}
	done := make(chan outcome, 1)

	go func() {
		var buf bytes.Buffer
		i := interp.New(interp.Options{Stdout: &buf})
		if err := i.Use(stdlib.Symbols); err != nil {
			done <- outcome{out: buf.String(), err: err}
			return
		}
		imps, body := hoistImports(code)
		full := "package main\n\n" + imps + "func main() {\n" + body + "\n}"
		if _, err := i.Eval(full); err != nil {
			done <- outcome{out: buf.String(), err: err}
			return
		}
		done <- outcome{out: buf.String()}
	}()

	select {
	case r := <-done:
		if r.err != nil {
			if r.out != "" {
				return r.out + "Error: " + r.err.Error() + "\n"
			}
			return "Error: " + r.err.Error()
		}
		return r.out
	case <-time.After(timeout):
		return "Error: execution timed out after " + timeout.Round(time.Millisecond).String()
	}
}