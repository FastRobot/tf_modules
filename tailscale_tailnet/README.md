# tailscale_tailnet

Manages a tailnet's policy document and tailnet-wide settings.

## Requirements

* An existing tailnet. The Tailscale provider cannot create one, and it
  cannot configure a custom OIDC identity provider — that happens once, by
  hand, at tailnet creation.
* An OAuth client with write scope for ACLs and tailnet settings.

## Gotchas

* `tailscale_federated_identity` is workload identity federation for the API,
  not user SSO. It is not what configures login.
* Leave `users_approval_on` false until every intended user has logged in at
  least once.
