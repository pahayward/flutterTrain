---
id: 03-time
title: time
order: 3
section: 06-stdlib
language: golang
summary: time.Time values, durations, layout-based formatting, arithmetic, and timers/tickers.
tags: [time, duration, layouts, ticker, timer]
---

# time

Time in Go is a first-class value, not a floating-point seconds counter. You
work with two main types:

- `time.Time` — a specific moment in time ("2026-09-17 14:30:00 UTC").
- `time.Duration` — a span of time, expressed in **nanoseconds** under the hood.

Get them with `time.Now()` and `time.Since(t)`.

```go
import (
	"fmt"
	"time"
)

start := time.Now()
elapsed := time.Since(start)
fmt.Println("now:", start.Format("15:04:05"))
fmt.Println("elapsed:", elapsed)
fmt.Printf("nanoseconds: %d\n", elapsed.Nanoseconds())
```

> [!key]
> A `time.Duration` is an `int64` count of nanoseconds. The package gives you
> constants like `time.Second` (1 billion ns), so you write `time.Second * 5`
> — never raw numbers.

## Duration arithmetic

Durations add and subtract naturally, and you can scale them with
multiplication:

- `later := start.Add(2 * time.Hour)`
- `earlier := start.Add(-30 * time.Minute)`
- `d := later.Sub(earlier)` → a `Duration`

```go
import (
	"fmt"
	"time"
)

start := time.Now()
in2h := start.Add(2 * time.Hour)
back30 := start.Add(-30 * time.Minute)

fmt.Println("in 2h:    ", in2h.Format("15:04"))
fmt.Println("30m ago:  ", back30.Format("15:04"))
fmt.Println("span:     ", in2h.Sub(back30)) // 2h30m
fmt.Println("shorter?  ", back30.Before(in2h))
```

> [!trap]
> `time.Now().Sub(time.Now())` bounces around zero because each call takes its
> own snapshot. Capture the moment **once** in a variable and compute against
> it.

## Formatting with the reference layout

Go does **not** use `%Y-%m-%d` placeholders. Instead you write an example
layout built from the magic reference time:

```
Mon Jan 2 15:04:05 MST 2006
```

Whatever parts you copy from that reference string become the format:

- `"2006-01-02"` → `2026-09-17`
- `"15:04:05"` → `14:30:00`
- `"Jan 2, 2006"` → `Sep 17, 2026`

```go
import (
	"fmt"
	"time"
)

t := time.Date(2026, time.September, 17, 14, 30, 5, 0, time.UTC)
fmt.Println("ISO date:    ", t.Format("2006-01-02"))
fmt.Println("clock:       ", t.Format("15:04:05"))
fmt.Println("friendly:    ", t.Format("Mon, Jan 2, 2006 at 3:04PM"))
fmt.Println("month name:  ", t.Format("January"))
fmt.Println("12-hour:     ", t.Format("3:04 PM"))
```

> [!note]
> The year must be **2006**, the month **Jan**, the day in the format must be
> **2**, and hours are **15** (24h) or **3** (12h). Get one digit wrong and
> you silently format the wrong thing.

## Parsing a string into a time

The same layout string is used the other way with `time.Parse`:

```go
import (
	"fmt"
	"time"
)

parsed, err := time.Parse("2006-01-02", "2026-12-25")
if err != nil {
	fmt.Println("parse error:", err)
} else {
	fmt.Println("day of week:", parsed.Weekday())
	fmt.Println("day of year:", parsed.YearDay())
}

next, _ := time.Parse("15:04", "23:59")
fmt.Println("minutes-in-day:", next.Hour()*60+next.Minute())
```

## Comparing and picking fields

`Time` exposes handy field selectors and comparisons:

- `.Year()`, `.Month()`, `.Day()`, `.Weekday()`
- `.After(other)`, `.Before(other)`, `.Equal(other)`
- `.Unix()` → seconds since the epoch as an `int64`

## Timers and tickers

- `time.Sleep(d)` — pause the current goroutine for a duration.
- `time.NewTimer(d)` — fires **once** after `d`; read from `<-timer.C`.
- `time.NewTicker(d)` — fires **repeatedly** every `d`; read from `<-ticker.C`.

Tickers are the heartbeat of background jobs: polling, keep-alives, logs.

```go
import (
	"fmt"
	"time"
)

done := make(chan bool)
timer := time.NewTimer(40 * time.Millisecond)
go func() {
	<-timer.C
	print("timer fired!\n")
	done <- true
}()

<-done

ticker := time.NewTicker(25 * time.Millisecond)
count := 0
for range ticker.C {
	count++
	fmt.Println("tick", count)
	if count == 3 {
		ticker.Stop()
		break
	}
}
fmt.Println("stopped ticker after", count, "ticks")
```

> [!warning]
> Always call `ticker.Stop()` when you're done, or a goroutine may leak.
> `Timer`/`Ticker` channels are buffered with capacity one, so stopping does
> not block.

## Quiz

```yaml
questions:
  - id: q1
    prompt: "What does a time.Duration store under the hood?"
    type: single
    choices:
      - "Seconds as a float64"
      - "Nanoseconds as an int64"
      - "A formatted string"
      - "Milliseconds as a time.Time"
    answer: [1]
    explanation: "Duration is an int64 nanosecond count; the time.Second constants make the raw numbers readable."
    difficulty: 1
  - id: q2
    prompt: "Which layout formats a time as 'YYYY-MM-DD'?"
    type: single
    choices:
      - "\"1010-01-01\""
      - "\"2006-01-02\""
      - "\"YYYY-MM-DD\""
      - "\"%Y-%m-%d\""
    answer: [1]
    explanation: "Go layout uses the reference time 2006-01-02, so the calendar-date layout is \"2006-01-02\"."
    difficulty: 2
  - id: q3
    prompt: "What is the difference between a Timer and a Ticker?"
    type: single
    choices:
      - "Timer fires once; Ticker fires repeatedly"
      - "Timer is for sleeps; Ticker for timeouts"
      - "They are identical; the names are legacy"
      - "Ticker fires only on weekends"
    answer: [0]
    explanation: "NewTimer sends one value on C after the duration; NewTicker sends values repeatedly at fixed intervals."
    difficulty: 2
  - id: q4
    prompt: "How do you compute the duration elapsed since a captured time t?"
    type: single
    choices:
      - "t.Sub(time.Now())"
      - "time.Since(t)"
      - "elapsed := -t"
      - "time.After(t)"
    answer: [1]
    explanation: "time.Since(t) is shorthand for time.Now().Sub(t), returning how long ago t was."
    difficulty: 1
```