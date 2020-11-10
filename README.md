# icap-terraform-aks-deployment

The steps below are what is required to stand up a working cluster running the latest ICAP stack.

Before you begin, please make sure you're logged into Azure-CLI with a valid Azure subscription and permissions create and destroy resources. You will also need to clone this repo down before you start, so you have access to all the resources.

## Create Azure storage account, blob storage, File share and Azure Key Vault

So within the folder (insert folder name) you will find a script ***create-az-storage-account.sh*** - run the script to create the Azure storage account and blob storage. The script creates the following resources:

- Resource group
- Storage account
- Blob container
- File share
- Key Vault

You should see the following output once the script completes

```bash
storage_account_name: tfstate
container_name: gw-icap-tfstate-test
access_key: <access key>
vault_name: gw-tfstate-vault-test
```

Please take note of these outputs, as they will be needed later on.

Create a new secret called "terraform-backend-key" in the key vault and add the value of the storage access key created previously

```bash
az keyvault secret set --vault-name “<vault name>” --name “terraform-backend-key” --value <the value of the access_key key>
```

Now verify you can read the value of the created secret

```bash
az keyvault secret show --name terraform-backend-key --vault-name <vault name> --query value -o tsv
```

Next export the environment variable "ARM_ACCESS_KEY" to be able to initialise terraform

```bash
export ARM_ACCESS_KEY=$(az keyvault secret show --name terraform-backend-key --vault-name <vault name> --query value -o tsv)

# now check to see if you can access it through variable

echo $ARM_ACCESS_KEY
```
*You can add the above to your .bashrc or .zshrc file if needed*
## Create Terraform Principal

Next we will need to create a service principle that Terraform will use to authenticate to Azure RBAC. You will not need to log in as the service principle but you will need to add the details that get created into the Azure Vault we created earlier on. Terraform will then use these credentials to authenticate to Azure.

The script can be found in (folder name) and it is called *createTerraformServicePrinciple.sh*. Running the script will create the following:

- Service Principle
- Update or create *provider.tf* file

When the script runs you will be prompted with 

```bash
The provider.tf file exists.  Do you want to overwrite? [Y/n]:
```

Please enter "no" as the provider.tf file already exists within the repo.

Once the script has run take note of the Username and password for the service account, as we will then need to add it to Azure Key Vault.

## Add Service Principle to Azure Key Vault

The below commands will add the service principle credentials into the Azure Key Vault. Please note that the names need to match exactly otherwise the Terraform code will not be able to retrieve them.

Use the following to add the secrets:

```bash
az keyvault secret set --vault-name gw-tfstate-vault-test --name spusername --value <ClientID-Secret>

az keyvault secret set --vault-name gw-tfstate-vault-test --name sppassword --value <Client-Secret>
```

## Initialise Terraform and deploy to Azure

We will next be initialising Terraform and making sure everything is ready to be deployed.

All of the below commands are run in the root folder:

```bash
terraform init
```

Next run terraform validate/refresh to check for changes within the state, and also to make sure there aren't any issues.

```bash
terraform validate
Success! The configuration is valid.

terraform refresh
```

Now you're ready to run apply and it should give you the following output

```bash
terraform apply

Plan: 1 to add, 2 to change, 1 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

Enter "yes" and wait for it to complete

Once this completes you should see all the infrastructure for the AKS deployed and working.

## Deploy Helm Charts to the cluster

Before we begin you will need to run the following command to get the details of the cluster that has just been deployed.

```bash
az aks get-credentials --name gw-icap-aks --resource-group gw-icap-aks-deploy
```

In this stage we will be deploying the helm charts to the newly created cluster. Before we jump right into deploying the charts, there is some house keeping that needs to be done. We will need to add some secrets the Kubernetes in order for some of the services to do the following:

- Access File Share in an Azure Storage account
- Pull private images from DockerHub

We can achieve this with the script *create-ns-secrets.sh* which will add do the following:

- Creates all namespaces for ICAP services
- Add secrets for the following
  - Dockerhub Service Account
  - File Share account name and account key
  - Certs for TLS

Before running this script you need run the below command to create the TLS certs.

```bash
openssl req -newkey rsa:2048 -nodes -keyout tls.key -x509 -days 365 -out certificate.crt
```

Once this script has completed, we can move onto deploying the services to the cluster.

### Deploy services

Next we will deploy the charts using Helm, please follow commands below:

***All commands need to be run from the root directory for the paths to be correct***

#### Adaptation & RabbitMQService

```bash
helm install ./adaptation -n icap-adaptation --generate-name

helm install ./rabbitmq -n icap-adaptation --generate-name
```

The adaptation service does tend to restart 5/6 times before it hits *Running* status.

You will then need to run the following command to enable plugins on the rabbitmq pod.

```bash
kubectl exec -it -n icap-adaptation rabbitmq-controller-<pod name> -- /bin/bash -c "rabbitmq-plugins enable rabbitmq_management"
```

Finally if you want to check that RabbitMQ is up and running you can use the following to check the console

```bash
kubectl port-forward -n icap-adaptation rabbitmq-controller-747n4 8080:15672
```

Then you can access it via [http://localthost:8080/](http://localthost:8080/)

#### Management UI

```bash
helm install ./administration/management-ui -n management-ui --generate-name
```

#### Transaction Event API

```bash
helm install ./administration/transactioneventapi -n transaction-event-api --generate-name
```