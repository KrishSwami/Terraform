terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

# Configure the GitHub Provider
provider "github" {
    token = "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"
}

resource "github_repository" "example" {
  name        = "Terraform_Codebase"
  description = "My awesome codebase"

  visibility = "public"
  auto_init = true

}

resource "github_repository" "hello" {
  name        = "Java_Codebase"
  description = "My awesome JAVA codebase"

  visibility = "public"
  auto_init = true

}