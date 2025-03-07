# For more information go to:
# https://www.nathannellans.com/post/deploying-bicep-files-part-6-scopes-stacks

# Deployment Stacks at the Resource Group scope
az stack group create \
  --action-on-unmanage deleteAll|deleteResources|detachAll \    # aka --aou
  --deny-settings-mode denyDelete|denyWriteAndDelete|none \     # aka --dm
  --name <stackName> \
  --resource-group <rgName> \                                   # aka -g
  --bypass-stack-out-of-sync-error false|true \                 # aka --bse. Optional. Default: false
  --deny-settings-apply-to-child-scopes \                       # aka --cs. Optional
  --deny-settings-excluded-actions <actions> \                  # aka --ea. Optional
  --deny-settings-excluded-principals <principalIDs> \          # aka --ed. Optional
  --description <description> \                                 # Optional
  --tags <kvpairs> \                                            # Optional
  --no-wait false|true \                                        # Optional. Default: false
  --parameters <file> \                                         # Optional
  --parameters <json> \                                         # Optional
  --parameters key1=value key2=value \                          # Optional
  --template-file <bicepFile> \                                 # aka -f
  --template-spec <specId> \                                    # aka -s
  --template-uri <remoteUri> \                                  # aka -u
  --yes

# Deployment Stacks at the Subscription scope
az stack sub create \
  --location <region> \
  --name <deploymentName> \                                                             # Optional. Default: name of the Bicep file
  --template-file <main.bicep> \
  --parameters <main.bicepparam> \                                                      # Optional
  --parameters Key1='Value1' Key2='Value2' \                                            # Optional
  --what-if | --confirm-with-what-if | --confirm-with-what-if --proceed-if-no-change    # Optional, choose one

# Deployment Stacks at the Management Group scope
az deployment mg create \
  --location <region> \
  --management-group-id <mgId> \
  --name <deploymentName> \                                                             # Optional. Default: name of the Bicep file
  --template-file <main.bicep>
  --parameters <main.bicepparam> \                                                      # Optional
  --parameters Key1='Value1' Key2='Value2' \                                            # Optional
  --what-if | --confirm-with-what-if | --confirm-with-what-if --proceed-if-no-change    # Optional, choose one

# Deployment Stacks at the Tenant scope
az stack tenant create \
  --location <region> \
  --name <deploymentName> \                                                             # Optional. Default: name of the Bicep file
  --template-file <main.bicep> \
  --parameters <main.bicepparam> \                                                      # Optional
  --parameters Key1='Value1' Key2='Value2' \                                            # Optional
  --what-if | --confirm-with-what-if | --confirm-with-what-if --proceed-if-no-change    # Optional, choose one
