# zitadel_oidc_app

Creates a ZITADEL project, an OIDC application, human users, and their grants.

Built for federating a custom email domain into Tailscale, but is generic to
any OIDC relying party.

## Requirements

* ZITADEL 4.x — `zitadel_human_user` uses the user/v2 API
* A service user with Org Owner rights, and its JWT profile key

## Gotchas

* `is_email_verified` can only be true when a password is set. By default the
  bootstrap password is randomly generated per user (`random_password`); set
  `initial_passwords[key]` only to override it for a specific user. A single
  `local.effective_passwords` expression decides the actual password set on
  the account *and* is what the `initial_passwords` output returns, so the
  two can never diverge — no random password is even generated for a user
  whose key is present in `var.initial_passwords`.
* The bootstrap password actually set on the account (override or generated)
  is retrievable once via `terragrunt output -json initial_passwords`. It's a
  throwaway credential — the expectation is you log in once, then enroll a
  passkey, after which the password is no longer needed.
* `initial_skip_password_change` is set to `true`. Without it the user is
  forced through a password-change screen on first login, which breaks
  relying-party enrollment redirects.
* `client_id` and `client_secret` are read-only and sensitive but still land
  in Terraform state.
* Passkey and OTP enrollment cannot be automated; the provider explicitly does
  not initialise passwordless setup. Enroll manually after first login.
* `zitadel_human_user.initial_password` is a write-only provider attribute,
  which requires Terraform >= 1.11.
* **`org_id` is effectively required whenever `var.users` is non-empty, despite
  the provider docs.** The docs for `zitadel_human_user` say `org_id` falls back
  to the authenticated service account's organization when omitted — that claim
  is only true for the v1-API resources (`zitadel_project`,
  `zitadel_application_oidc`). `zitadel_human_user` uses the user/v2 API, which
  sends an empty string instead of resolving a fallback, and ZITADEL rejects it
  with a gRPC `InvalidArgument` (`invalid CreateUserRequest.OrganizationId:
  value length must be between 1 and 200 runes, inclusive`) — at apply time,
  after the project and app have already been created. A `lifecycle
  precondition` on `zitadel_human_user` now fails fast with a clear message
  instead of that cryptic gRPC error; set `var.org_id` explicitly any time
  you're also passing `var.users`.

## Usage

See `live/home/global/zitadel_idp` in the `live` repo.
