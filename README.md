# Terraform modules by FastRobot

This is a collection of modules in use by FastRobot. We typically call them
via `terragrunt`. Each top-level directory is its own self-contained module.

# pre-commit
```bash
brew install pre-commit tflint tfsec checkov terraform-docs
precommit run -a
```

## Modules

* `elk` - stands up an AWS ES endpoint and an instance running logstash
