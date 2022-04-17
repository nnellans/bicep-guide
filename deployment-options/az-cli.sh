# For more information go to:
# https://www.nathannellans.com/post/deploying-bicep-files-part-2-az-cli

# Deploy Bicep to a Resource Group
az deployment group create \
  --resource-group <rgName> \
  --subscription <subName> \                                                            # Optional. Default: currently logged in Subscription
  --mode Incremental | Complete \                                                       # Optional. Default: Incremental
  --rollback-on-error | --rollback-on-error <name> \                                    # Optional, choose one
  --name <deploymentName> \                                                             # Optional. Default: name of the Bicep file
  --template-file <template.bicep> \
  --parameters <template.parameters.json> \                                             # Optional
  --parameters Key1='Value1' Key2='Value2' \                                            # Optional
  --what-if | --confirm-with-what-if | --confirm-with-what-if --proceed-if-no-change    # Optional, choose one

# Deploy Bicep to a Subscription
az deployment sub create \
  --location <region> \
  --name <deploymentName> \                                                             # Optional. Default: name of the Bicep file
  --template-file <template.bicep> \
  --parameters <template.parameters.json> \                                             # Optional
  --parameters Key1='Value1' Key2='Value2' \                                            # Optional
  --what-if | --confirm-with-what-if | --confirm-with-what-if --proceed-if-no-change    # Optional, choose one

# Deploy Bicep to a Management Group
az deployment mg create \
  --location <region> \
  --management-group-id <mgId> \
  --name <deploymentName> \                                                             # Optional. Default: name of the Bicep file
  --template-file <template.bicep>
  --parameters <template.parameters.json> \                                             # Optional
  --parameters Key1='Value1' Key2='Value2' \                                            # Optional
  --what-if | --confirm-with-what-if | --confirm-with-what-if --proceed-if-no-change    # Optional, choose one

# Deploy Bicep to a Tenant
az deployment tenant create \
  --location <region> \
  --name <deploymentName> \                                                             # Optional. Default: name of the Bicep file
  --template-file <template.bicep> \
  --parameters <template.parameters.json> \                                             # Optional
  --parameters Key1='Value1' Key2='Value2' \                                            # Optional
  --what-if | --confirm-with-what-if | --confirm-with-what-if --proceed-if-no-change    # Optional, choose one
