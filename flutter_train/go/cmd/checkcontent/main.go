// Command checkcontent smoke-runs every runnable ```go block found in the
// given courseware markdown files through the engine's yaegi sandbox.
//
//   go run ./cmd/checkcontent file1.md file2.md ...
//
// Exit status is 0 if all runnable blocks pass or are marked eval=no.
package main

import (
	"fmt"
	"os"
	"os/exec"
	"regexp"
	"strings"

	"fluttertrain.goengine"
)

var fence = regexp.MustCompile("(?ms)^```(go)([^\n]*)\n(.*?)^```")

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "usage: checkcontent file.md ...")
		os.Exit(2)
	}
	failed := 0
	total := 0
	for _, arg := range os.Args[1:] {
		data, err := os.ReadFile(arg)
		if err != nil {
			fmt.Println(err)
			failed++
			continue
		}
		for _, m := range fence.FindAllStringSubmatch(string(data), -1) {
			lang, info, code := m[1], m[2], m[3]
			if lang != "go" || strings.Contains(info, "eval=no") {
				continue
			}
			total++
			out := goengine.Run(code, 8000)
			if strings.Contains(out, "\nError:") || strings.HasPrefix(out, "Error:") {
				failed++
				fmt.Printf("FAIL %s\n  ERR  %s\n", arg, firstLine(out))
			} else {
				fmt.Printf("ok   %s  %s\n", arg, firstLine(strings.TrimRight(out, "\n")))
			}
		}
	}
	fmt.Printf("runnable=%d failed=%d\n", total, failed)
	if failed > 0 {
		os.Exit(1)
	}
}

func firstLine(s string) string {
	if s == "" {
		return "(no output)"
	}
	l := strings.SplitN(s, "\n", 2)[0]
	if len(l) > 70 {
		l = l[:70]
	}
	return l
}

var _ = exec.Command // keep os/exec available for future extension