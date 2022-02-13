terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}

# Configure the GitHub Provider
provider "github" {
  #token = var.atlantis_github_user_token
  token = data.aws_ssm_parameter.token.value
  owner = var.atlantis_github_organization
}
