# Stage 1: Node.js build
FROM node:20 AS node-builder

WORKDIR /src

COPY src/package.json src/package-lock.json ./
RUN npm ci

COPY src/tailwind.config.js ./
COPY src/css/input.css ./
COPY ui ../ui
COPY app/pages ../app/pages

RUN npm run build

# Stage 2: Go build
FROM golang:1.23 AS go-builder

WORKDIR /repo

# Install templ
RUN go install github.com/a-h/templ/cmd/templ@latest

COPY app/go.mod app/go.sum ./app/
COPY app/go.work app/go.work.sum ./app/

COPY ui/go.mod ui/go.sum ./ui/

RUN for f in $(find . -name go.mod) ; do (cd $(dirname $f); go mod download) ; done

COPY ui ./ui
COPY app ./app
RUN templ generate

COPY --from=node-builder /src/dist/ ./app/cmd/web/static/

WORKDIR /repo/app

RUN CGO_ENABLED=0 GOOS=linux go build -o /bin/web ./cmd/web

# Stage 3: Production
FROM alpine:3.18

RUN apk --no-cache add ca-certificates

WORKDIR /app

COPY --from=go-builder /bin/web /app/bin/web

# Create a non-root user
RUN adduser -D appuser
USER appuser

EXPOSE 8080

CMD ["/app/bin/web"]