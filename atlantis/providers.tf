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
  token = data.aws_ssm_parameter.github_token.value
  owner = var.atlantis_github_organization
}
