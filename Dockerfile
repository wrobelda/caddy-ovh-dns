FROM caddy:builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/ovh \
 && go clean -modcache \
 && rm -rf /root/.cache/go-build

FROM caddy:latest

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
