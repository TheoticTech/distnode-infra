# Getting Started

## Configure Terraform State Backend
```sh
cat <<EOT >> backends/dev.tfbackend
bucket      = "space-name"
key         = "terraform/dev.tfstate"
access_key  = "space-access-key"
secret_key  = "space-secret-key"
EOT
```

## Initialize Terraform
```sh
bash scripts/switchenv.sh dev
```

## Terraform Plan
```sh
bash scripts/plan.sh dev
```

## Terraform Apply
```sh
bash scripts/apply.sh dev
```
