# For more information go to:
# https://www.nathannellans.com/post/deploying-bicep-files-part-6-scopes-stacks

# Deployment Stacks at the Resource Group scope
az stack group create \
  --name <stackName> \                                          # aka -n. name of the Stack
  --action-on-unmanage deleteAll|deleteResources|detachAll \    # aka --aou
  --deny-settings-mode denyDelete|denyWriteAndDelete|none \     # aka --dm
  --resource-group <rgName> \                                   # aka -g. resource group to deploy the Stack to
  --template-file <main.bicep> \                                # aka -f
  --parameters <main.bicepparam> \                              # aka -p. Optional
  --parameters key1=value key2=value \                          # aka -p. Optional
  --bypass-stack-out-of-sync-error false|true \                 # aka --bse. Optional. Default: false
  --deny-settings-apply-to-child-scopes \                       # aka --cs. Optional
  --deny-settings-excluded-actions <actions> \                  # aka --ea. Optional
  --deny-settings-excluded-principals <principalIDs> \          # aka --ep. Optional
  --description <description> \                                 # Optional. description of the Stack
  --tags <kvpairs>                                              # Optional

# Deployment Stacks at the Subscription scope
az stack sub create \
  --name <stackName> \                                          # aka -n. name of the Stack
  --action-on-unmanage deleteAll|deleteResources|detachAll \    # aka --aou
  --deny-settings-mode denyDelete|denyWriteAndDelete|none \     # aka --dm
  --location <location> \                                       # aka -l. location to store Deployment Stack metadata
  --subscription <subName> \                                    # optional. subscription to deploy the stack to. default: current subscription
  --deployment-resource-group <rgName> \                        # aka --dr. optional. If deploying Stack to Sub and Bicep to RG
  --template-file <main.bicep> \                                # aka -f
  --parameters <main.bicepparam> \                              # aka -p. Optional
  --parameters key1=value key2=value \                          # aka -p. Optional
  --bypass-stack-out-of-sync-error false|true \                 # aka --bse. Optional. Default: false
  --deny-settings-apply-to-child-scopes \                       # aka --cs. Optional
  --deny-settings-excluded-actions <actions> \                  # aka --ea. Optional
  --deny-settings-excluded-principals <principalIDs> \          # aka --ep. Optional
  --description <description> \                                 # Optional. description of the Stack
  --tags <kvpairs>                                              # Optional

# Deployment Stacks at the Management Group scope
az stack mg create \
  --name <stackName> \                                          # aka -n. name of the Stack
  --action-on-unmanage deleteAll|deleteResources|detachAll \    # aka --aou
  --deny-settings-mode denyDelete|denyWriteAndDelete|none \     # aka --dm
  --location <location> \                                       # aka -l. location to store Deployment Stack metadata
  --management-group-id <mgId> \                                # aka -m. management group to deploy the stack to
  --deployment-subscription <subName> \                         # aka --ds. optional. If deploying Stack to Mg and Bicep to Sub
  --template-file <main.bicep> \                                # aka -f
  --parameters <main.bicepparam> \                              # aka -p. Optional
  --parameters key1=value key2=value \                          # aka -p. Optional
  --bypass-stack-out-of-sync-error false|true \                 # aka --bse. Optional. default: false
  --deny-settings-apply-to-child-scopes \                       # aka --cs. Optional
  --deny-settings-excluded-actions <actions> \                  # aka --ea. Optional
  --deny-settings-excluded-principals <principalIDs> \          # aka --ep. Optional
  --description <description> \                                 # Optional. description of the Stack
  --tags <kvpairs>                                              # Optional
