# For more information go to:
# https://www.nathannellans.com/post/deploying-bicep-files-part-6-scopes-stacks

# Deployment Stacks at the Resource Group scope
az stack group create \
  --name <stackName> \                                          # aka -n
  --resource-group <rgName> \                                   # aka -g
  --action-on-unmanage deleteAll|deleteResources|detachAll \    # aka --aou
  --deny-settings-mode denyDelete|denyWriteAndDelete|none \     # aka --dm
  --template-file <main.bicep> \                                # aka -f
  --parameters <main.bicepparam> \                              # aka -p. Optional
  --parameters key1=value key2=value \                          # aka -p. Optional
  --bypass-stack-out-of-sync-error false|true \                 # aka --bse. Optional. Default: false
  --deny-settings-apply-to-child-scopes \                       # aka --cs. Optional
  --deny-settings-excluded-actions <actions> \                  # aka --ea. Optional
  --deny-settings-excluded-principals <principalIDs> \          # aka --ed. Optional
  --description <description> \                                 # Optional
  --tags <kvpairs>                                              # Optional
  

# Deployment Stacks at the Subscription scope


# Deployment Stacks at the Management Group scope
