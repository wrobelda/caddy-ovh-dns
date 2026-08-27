FROM --platform=$BUILDPLATFORM docker.io/library/caddy:builder AS builder

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

# fall back to direct VCS downloads on any module-proxy error, not just 404s
ENV GOPROXY="https://proxy.golang.org|direct"

RUN GOOS=$TARGETOS GOARCH=$TARGETARCH GOARM=${TARGETVARIANT#v} xcaddy build \
    --with github.com/caddy-dns/ovh \
 && go clean -modcache \
 && rm -rf /root/.cache/go-build

FROM docker.io/library/caddy:latest

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
