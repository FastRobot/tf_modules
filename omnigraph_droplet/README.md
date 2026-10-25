# omnigraph_droplet

One [OmniGraph](https://github.com/ModernRelay/omnigraph) server on a
DigitalOcean droplet, published through a Cloudflare Tunnel behind Cloudflare
Access with Google login.

```
browser ── Access (Google, explicit emails) ── tunnel ── cloudflared ── caddy:8081 ── omnigraph:8080
client  ── Access (service token)           ── tunnel ── cloudflared ── caddy:8082 ── omnigraph:8080
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
scp -r ./my-bundle root@<droplet>:/root/
ssh root@<droplet>
cd /root
og cluster validate --config /work/my-bundle
og cluster apply --target /var/lib/omnigraph/cluster --config /work/my-bundle --as act-you --json
# apply exits holding the cluster admission lock; it printed the lock ID.
og --target file:///var/lib/omnigraph/cluster cluster force-unlock '<LOCK_ID>'
cd /etc/omnigraph && docker compose --profile serve up -d
```

Later schema, query and policy changes go to the running server
(`omnigraph cluster apply --target <server target>`), not through `og`, because
direct writes need the server stopped.

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
