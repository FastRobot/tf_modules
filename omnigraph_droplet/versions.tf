terraform {
  required_version = ">= 1.5"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.28"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.106"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
