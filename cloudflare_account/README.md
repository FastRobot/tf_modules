# cloudflare_account

Account-wide Cloudflare resources shared by services:

* `cloudflare_zone` for each name in `zones`, set up as `full` (Cloudflare serves
  the zone's DNS). Tunnel hostnames on the free plan need a full zone.
* A Google identity provider for Cloudflare Zero Trust Access, when
  `google_oauth_client_id` is set.

No provider block: the caller configures `cloudflare`. The provider reads
`CLOUDFLARE_API_TOKEN` from the environment.

## Manual prerequisites

1. Zero Trust onboarding in the dashboard (choose a team name and the free plan).
2. A Google Cloud OAuth client of type "Web application" with authorized
   redirect URI `https://<team>.cloudflareaccess.com/cdn-cgi/access/callback`.
3. An account API token (Manage account > Account API tokens) with two
   permission policies. Names are as the dashboard and
   `GET /accounts/{id}/tokens/permission_groups` show them:
   * Account scope, this account: "Access: Organizations, Identity Providers,
     and Groups Write", "Access: Apps and Policies Write", "Access: Service
     Tokens Write", "Cloudflare Tunnel Write".
   * Zone scope, the managed zones (or all zones in the account): "Zone Read"
     and "DNS Write". Add "Zone Write" only to create or delete zones from
     Terraform. Without a zone-scoped policy, record creation fails with
     `Authentication error` (code 10000) even though account permissions work.

After the first apply, set the registrar's nameservers to `name_servers`.
