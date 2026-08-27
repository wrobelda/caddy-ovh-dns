# caddy-ovh-dns

A stock [Caddy](https://caddyserver.com/) image extended with the
[caddy-dns/ovh](https://github.com/caddy-dns/ovh) module, so Caddy can obtain
and renew its TLS certificates through the ACME DNS-01 challenge using OVH's
DNS API. This is the right setup when the host is not reachable from the
internet, because DNS-01 proves domain control purely through DNS records and
never needs an inbound connection.

The image is rebuilt from `caddy:builder`/`caddy:latest` on every push and
published as:

```
ghcr.io/wrobelda/caddy-ovh:latest
```

## Usage

The OVH credentials are passed through the environment; the module expects an
application key/secret pair plus a consumer key with access to the zone's
record and refresh paths (see [OVH's API documentation](https://help.ovhcloud.com/csm/en-api-getting-started-ovhcloud-api)
or [ovh-subdomain-provision](../ovh-subdomain-provision/), which generates a zone-limited consumer
key for exactly this purpose).

```yaml
# docker-compose.yml
services:
  caddy:
    image: ghcr.io/wrobelda/caddy-ovh:latest
    restart: unless-stopped
    ports:
      - "443:443"
      # - "80:80"  # only if you want Caddy's HTTP -> HTTPS redirect;
    environment:
      OVH_ENDPOINT: ovh-eu           # ovh-eu | ovh-ca | ovh-us
      OVH_APPLICATION_KEY: ...
      OVH_APPLICATION_SECRET: ...
      OVH_CONSUMER_KEY: ...
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config

volumes:
  caddy_data:
  caddy_config:
```

```Caddyfile
{
    # if you publish "80:80" in docker-compose.yml, remove this to get the
    # HTTP -> HTTPS redirect
    auto_https disable_redirects
}

subdomain.example.com {
    tls {
        dns ovh {
            endpoint {env.OVH_ENDPOINT}
            application_key {env.OVH_APPLICATION_KEY}
            application_secret {env.OVH_APPLICATION_SECRET}
            consumer_key {env.OVH_CONSUMER_KEY}
        }
    }
    reverse_proxy localhost:8080
}
```

The `caddy_data` volume holds the issued certificates and ACME account, so
renewals survive container recreation.
