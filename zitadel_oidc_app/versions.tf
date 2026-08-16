terraform {
  required_version = ">= 1.0"

  required_providers {
    zitadel = {
      source  = "zitadel/zitadel"
      version = ">= 1.2.0"
    }
  }
}
