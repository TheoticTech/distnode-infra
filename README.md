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
# Token secrets can be generated using the following:
# node -e "console.log(require('crypto').randomBytes(256).toString('base64'));"
auth_server_deployment_csrf_token_secret = "csrf_token_secret"
auth_server_deployment_jwt_access_token_secret = "jwt_access_token_secret"
auth_server_deployment_jwt_refresh_token_secret = "jwt_refresh_token_secret"
email_address = "your-email-address" # Used for LetsEncrypt
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
**NOTE**: If errors are encountered, please read the "Important Notes" section below.

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

## Important Notes
The kubernetes_manifest.app_ingress resource depends on the
helm_release.ingress_nginx resource, which in turn requires HTTPS prior for
installation. The kubernetes_manifest.lets_encrypt_cluster_issuer  resources
requires a ClusterIssuer CRD. This is installed with the cert-manager helm
release. This means that you must have the helm_release.cert_manager installed
before you can use the LetsEncrypt cluster issuer.

1. Ensure Helm is installed and cert-manager repo is added
```sh
brew install helm
helm repo add jetstack https://charts.jetstack.io
helm repo update
```

2. Comment out the following resources:
```
kubernetes_manifest.app_ingress
kubernetes_manifest.lets_encrypt_cluster_issuer
helm_release.ingress_nginx
```
3. Run Terraform apply for cert-manager
4. Uncomment the LetsEncrypt issuer resources:
```
kubernetes_manifest.lets_encrypt_cluster_issuer
```
5. Run Terraform apply for LetsEncrypt issuer resources
6. Uncomment the ingress_nginx resource:
```
helm_release.ingress_nginx
```
7. Run Terraform apply for ingress_nginx resource
8. Uncomment the app_ingress resource:
```
kubernetes_manifest.app_ingress
```
9. Run Terraform apply for app_ingress resource
