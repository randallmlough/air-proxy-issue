# ==================================================================================== #
##@ Development
# ==================================================================================== #

.PHONY: dev
dev: ## run the application in development mode
	air -c .air.toml


build: gen assets ## build the application
	@cd ./app; go build -o=./../tmp/bin/web ./cmd/web

.PHONY: assets
assets: ## build web assets
	@cd ./src; npm run build
	@cp -r ./src/dist ./app/cmd/web/static

.PHONY: gen
gen: ## run code generator
	@templ generate

.PHONY: run
run: build ## run the application
	./tmp/bin/web


# ==================================================================================== #
##@ Maintenance
# ==================================================================================== #

.PHONY: dep
dep: ## install all dependencies
	@make dep/go
	@make dep/npm

.PHONY: dep/go
dep/go: ## install go dependencies
	for f in $(find . -name go.mod) ; do \
        (cd $(dirname $f); go mod tidy -v) ; \
    done

.PHONY: dep/npm
dep/npm: ## install node dependencies
	@cd ./src; npm i


# ==================================================================================== #
##@ Utilities
# ==================================================================================== #

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} \
	/^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } \
	/^[a-zA-Z0-9_-]+\/[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } \
	/^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) }' $(MAKEFILE_LIST)
