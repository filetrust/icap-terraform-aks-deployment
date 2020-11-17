#!/bin/bash

# This script will run create the neccesary namespaces and add the docker service account to the required namespace.

# Secret Variables
DOCKER_SERVER="https://index.docker.io/v1/"
USER_EMAIL="mpigram@glasswallsolutions.com"
DOCKER_USERNAME=$(az keyvault secret show --name DH-SA-USERNAME --vault-name gw-tfstate-vault-test --query value -o tsv)
DOCKER_PASSWORD=$(az keyvault secret show --name DH-SA-password --vault-name gw-tfstate-vault-test --query value -o tsv)
FILESHARE_ACCOUNT_NAME=$(az keyvault secret show --name file-share-account --vault-name gw-tfstate-vault-test --query value -o tsv)
FILESHARE_KEY=$(az keyvault secret show --name file-share-key --vault-name gw-tfstate-vault-test --query value -o tsv)

# Namespace Variables
NAMESPACE01="icap-adaptation"
NAMESPACE02="management-ui"
NAMESPACE03="transaction-event-api"
NAMESPACE04="prometheus-stack"
NAMESPACE05="rabbitmq-controller"

# Create namespaces for deployment
kubectl create ns $NAMESPACE01
kubectl create ns $NAMESPACE02
kubectl create ns $NAMESPACE03
kubectl create ns $NAMESPACE04
kubectl create ns $NAMESPACE05

# Create secret for Docker Registry - this only needs to be added to the 'icap-adaptation' namespace 
kubectl create -n $NAMESPACE01 secret docker-registry regcred \
	--docker-server=$DOCKER_SERVER \
	--docker-username=$DOCKER_USERNAME \
	--docker-password="$DOCKER_PASSWORD" \
	--docker-email=$USER_EMAIL

# Create secret for file share - needs to be part of the 'icap-adaptation' namespace
kubectl create -n $NAMESPACE01 secret generic transactionstoresecret --from-literal=accountName=$FILESHARE_ACCOUNT_NAME --from-literal=accountKey=$FILESHARE_KEY

# Create secret for TLS certs & keys - needs to be part of the 'icap-adaptation' namespace
kubectl create -n $NAMESPACE01 secret tls icap-service-tls-config --key tls.key --cert certificate.crt

