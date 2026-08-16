# zitadel_oidc_app

Creates a ZITADEL project, an OIDC application, human users, and their grants.

Built for federating a custom email domain into Tailscale, but is generic to
any OIDC relying party.

## Requirements

* ZITADEL 4.x — `zitadel_human_user` uses the user/v2 API
* A service user with Org Owner rights, and its JWT profile key

## Gotchas

* `is_email_verified` can only be true when a password is set, so
  `initial_passwords` must carry an entry for every user.
* `initial_skip_password_change` is set to `true`. Without it the user is
  forced through a password-change screen on first login, which breaks
  relying-party enrollment redirects.
* `client_id` and `client_secret` are read-only and sensitive but still land
  in Terraform state.
* Passkey and OTP enrollment cannot be automated; the provider explicitly does
  not initialise passwordless setup. Enroll manually after first login.

## Usage

See `live/home/global/zitadel_idp` in the `live` repo.
