# initial setup

```bash
az login                # opens browser; if headless: az login --use-device-code
az account list -o table
az account set --subscription "XXXXXX-XXXX-XXX-XXX-XXX"
az account show -o table   # verify the active subscription
```

## tfstate
```bash
RG="rg-tfstate"
LOC="westeurope"
SA="tfstate$RANDOM"     # must be globally unique
CONTAINER="tfstate"

az group create -n "$RG" -l "$LOC"
az storage account create -g "$RG" -n "$SA" -l "$LOC" --sku Standard_LRS --encryption-services blob
ACCOUNT_KEY="$(az storage account keys list -g "$RG" -n "$SA" --query '[0].value' -o tsv)"
az storage container create --name "$CONTAINER" --account-name "$SA" --account-key "$ACCOUNT_KEY"
```


## backend
```bash
terraform init \
  -backend-config="resource_group_name=$RG" \
  -backend-config="storage_account_name=$SA" \
  -backend-config="container_name=$CONTAINER" \
  -backend-config="key=global.tfstate"

```

## first try
```bash
terraform init
terraform plan -out myplan01.tfplan
terraform apply myplan01.tfplan 

```
