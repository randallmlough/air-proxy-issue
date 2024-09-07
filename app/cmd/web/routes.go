package main

import (
	"embed"
	"net/http"

	"github.com/a-h/templ"
	"github.com/go-chi/chi/v5"
	"github.com/justplanecoffee/jpc/pages"
)

//go:embed "static"
var WebAssets embed.FS

func (app *application) routes() http.Handler {
	mux := chi.NewRouter()

	mux.Use(app.securityHeaders)

	fileServer := http.FileServer(http.FS(WebAssets))
	mux.Handle("/static/*", fileServer)

	mux.Get("/", templ.Handler(pages.Home()).ServeHTTP)

	return mux
}
