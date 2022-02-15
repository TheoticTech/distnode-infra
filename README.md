# Getting Started

## Project Setup
1. Create a new DigitalOcean (DO) project
2. Create a DO Space for the new project
3. Create a DO Personal Access Token (used for do_token in *tf.vars)
4. Create a DO Spaces Access Keys (used for access_key and secret_key values in *.tfbackend)
5. Set environment name variable
```
export ENV_NAME=<your_env_name>
```
6. Create a tfbackend file
```sh
cat <<EOT >> backends/$ENV_NAME.tfbackend
bucket      = "space-name"
key         = "terraform/$ENV_NAME.tfstate"
access_key  = "space-access-key"
secret_key  = "space-secret-key"
EOT
```
7. Create a tfvars file
```sh
cat <<EOT >> variables/$ENV_NAME.tfvars
deployment_mode = "initialize"
env = "$ENV_NAME"
do_project_name = "Digital Ocean Project Name"
do_tfstate_space_urn = "do:space:space-name"
do_token = "digitalocean-token"
auth_server_deployment_jwt_access_token_secret = "jwt_access_token_secret"
auth_server_deployment_jwt_refresh_token_secret = "jwt_refresh_token_secret"
EOT
```
8. Import the DO project into Terraform state
```sh
terraform init -reconfigure -backend-config=./backends/$ENV_NAME.tfbackend
terraform import -var-file=./variables/$ENV_NAME.tfvars digitalocean_project.distnode <project-id>
```
9. Create the Kubernetes cluster
```sh
terraform apply \
    -var-file=./variables/$ENV_NAME.tfvars \
    -target=digitalocean_kubernetes_cluster.main_kubernetes_cluster
```
10. Set the deployment mode to "deploy"
```sh
# deployment_mode = "initialize" -> deployment_mode = "deploy"
sed -i '' "s/initialize/deploy/g" variables/$ENV_NAME.tfvars
```

## Resource Deployment

### Terraform Plan
```sh
bash scripts/plan.sh $ENV_NAME
```

### Terraform Apply
```sh
bash scripts/apply.sh $ENV_NAME
```

## Cleanup

### Terraform Destroy
```sh
terraform destroy -var-file=./variables/$ENV_NAME.tfvars
```
