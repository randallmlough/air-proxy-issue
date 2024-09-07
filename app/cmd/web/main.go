package main

import (
	"flag"
	"log/slog"
	"os"
	"runtime/debug"
	"sync"

	"github.com/justplanecoffee/jpc/internal/env"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelDebug}))

	err := run(logger)
	if err != nil {
		trace := string(debug.Stack())
		logger.Error(err.Error(), "trace", trace)
		os.Exit(1)
	}
}

type application struct {
	baseURL  string
	httpPort int
	logger   *slog.Logger
	wg       sync.WaitGroup
}

func run(logger *slog.Logger) error {
	app := &application{
		logger: logger,
	}
	app.baseURL = env.GetString("BASE_URL", "http://localhost:8080")
	app.httpPort = env.GetInt("HTTP_PORT", 8080)

	flag.Parse()

	return app.serveHTTP()
}
