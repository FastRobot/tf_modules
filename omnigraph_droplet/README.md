# omnigraph_droplet

One [OmniGraph](https://github.com/ModernRelay/omnigraph) server on a
DigitalOcean droplet, published through a Cloudflare Tunnel behind Cloudflare
Access with Google login.

```
browser, MCP, og-cf-proxy (oauth)   ── Access (Google, explicit emails) ── tunnel ── cloudflared ── caddy:8081 ── omnigraph:8080
CI, og-cf-proxy (service)           ── Access (service token)           ── tunnel ── cloudflared ── caddy:8082 ── omnigraph:8080
```

* The droplet takes no inbound traffic except optional SSH (`ssh_source_addresses`)
  or Tailscale (`tailscale_auth_key`).
* cloudflared checks every request's Access JWT against the application audience.
* OmniGraph's built-in OIDC cannot take Google tokens. It requires `org_id` and
  `client_id` claims and lifetimes of at most 300 seconds. Identity is mapped
  instead: Caddy replaces the Access-authenticated email with that user's
  actor bearer token (generated here). Clients on `api_hostname` send their
  own bearer token plus their Access service token headers.
* The cluster root lives on its own volume (`prevent_destroy`) at
  `/mnt/omnigraph/cluster`. One droplet means one writer, the only topology
  OmniGraph supports.

Emails in `users` must match the address Google returns exactly. Caddy's
match is case-sensitive; the module lowercases keys, and Google addresses
are lowercase.

No provider blocks: the caller configures `cloudflare` (`CLOUDFLARE_API_TOKEN`)
and `digitalocean` (`DIGITALOCEAN_TOKEN`).

## First boot: bootstrap the cluster

A fresh volume holds no cluster, so cloud-init starts only Caddy and
cloudflared. Bootstrap once from a cluster bundle (`cluster.yaml`, schema,
policies). The policy must grant the actors in `users`/`service_clients`.

```bash
# og runs as the image's non-root user and mounts $PWD at /work, so keep
# bundles somewhere world-readable (not /root, which is 0700).
ssh root@<droplet> 'mkdir -p /srv/omnigraph-bundles'
scp -r ./my-bundle root@<droplet>:/srv/omnigraph-bundles/
ssh root@<droplet>
chmod -R a+rX /srv/omnigraph-bundles && cd /srv/omnigraph-bundles
og cluster validate --config /work/my-bundle
og cluster apply --target /var/lib/omnigraph/cluster --config /work/my-bundle --as act-you --json
# apply exits holding the cluster admission lock; it printed the lock ID.
og --target file:///var/lib/omnigraph/cluster cluster force-unlock '<LOCK_ID>'
cd /etc/omnigraph && docker compose --profile serve up -d
```

Later schema, query and policy changes go to the running server
(`omnigraph cluster apply --target <server target>`), not through `og`, because
direct writes need the server stopped.

## CLI and CI access: `tools/og-cf-proxy`

The omnigraph CLI cannot pass Cloudflare Access. It sends only a token68
bearer token, so it can't carry an Access OAuth token (`oauth:...`) or the
service-token headers. It does allow plain HTTP to an *anonymous loopback*
server. `tools/og-cf-proxy` (Python 3, stdlib only) listens on
`127.0.0.1:8787` and adds the credentials on the way out:

| Mode | Selected by | Upstream | Identity |
|---|---|---|---|
| oauth | default | `https://<hostname>` | Google login via Access Managed OAuth; Caddy maps the email to the actor |
| service | `CF_ACCESS_CLIENT_ID`, `CF_ACCESS_CLIENT_SECRET`, `OMNIGRAPH_TOKEN` set | `https://<api_hostname>` | the client's bearer token (`service_clients`) |

Workstation setup:

```bash
export OG_CF_UPSTREAM=https://<hostname>
og-cf-proxy login        # once; browser sign-in, refresh token kept in the macOS keychain
cat > ~/.omnigraph/config.yaml <<'YAML'
version: 1
targets:
  mine:
    kind: server
    endpoint: http://127.0.0.1:8787
    auth: {provider: anonymous}
    default_graph: <graph>
defaults:
  target: mine
YAML
og-cf-proxy exec -- omnigraph access --json     # or keep `og-cf-proxy serve` running
```

`exec` starts the proxy for one command, or reuses one already listening
with the same upstream. Access tokens last `oauth_access_token_lifetime`;
the proxy refreshes them, and a new `login` is needed after
`oauth_session_duration`. While the proxy runs, any local process that can
reach the port acts as you.

For CI, give the job a `service_clients` entry and its three values as
secrets, then run `og-cf-proxy exec -- omnigraph cluster apply --config ...`
with `OG_CF_UPSTREAM=https://<api_hostname>`. The client's actor needs
`config_manage` (cluster policy) plus `schema_apply` and `read` on each
graph whose schema changes.

MCP clients need no proxy. They discover Access Managed OAuth from the 401
on `https://<hostname>/mcp`.

## Changing users, clients or tokens

`user_data` only seeds a new droplet (`ignore_changes`), so replacing it never
kills a running writer. After an apply that changes `users` or
`service_clients`, push the two rendered files:

```bash
terragrunt output -raw caddyfile   | ssh root@<droplet> 'cat > /etc/omnigraph/Caddyfile && cd /etc/omnigraph && docker compose restart caddy'
terragrunt output -raw tokens_json | ssh root@<droplet> 'cat > /etc/omnigraph/tokens.json && cd /etc/omnigraph && docker compose --profile serve restart omnigraph'
```

The restart is a clean drain (`stop_grace_period` 40s > server grace 25s).

## Secrets at rest

Tokens and the tunnel token are in Terraform state and the droplet's
`user_data`, which any process on the droplet can read from the metadata service.
