#!/bin/bash
MANAGED_RG="aro-$(az aro show --name $1 --resource-group $2 --query "clusterProfile.domain" -o tsv)"
SA=$(az storage account list --resource-group $MANAGED_RG --query "[?starts_with(name, 'cluster')].name" -o tsv)

sed 's/MANAGED_SA/'"$SA"'/g' ./azure-file-sc.tpl > azure-file-sc.yaml

# deploy openshift gitops operator
oc apply -f . 

echo "azure file storage class created on cluster"