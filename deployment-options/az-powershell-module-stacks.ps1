# For more information go to:
# https://www.nathannellans.com/post/deploying-bicep-files-part-3-az-powershell-module

# Install the Az Module from PowerShell Gallery
Install-Module -Name Az

# Deployment Stacks at the Resource Group scope
New-AzResourceGroupDeploymentStack `
  -Name <name> `                                             # name of the Stack
  -ActionOnUnmanage deleteAll|deleteResources|detachAll `
  -DenySettingsMode denyDelete|denyWriteAndDelete|none `
  -ResourceGroupName <rgName> `                              # resource group to deploy the Stack to
  -TemplateFile <main.bicep> `
  -TemplateParameterFile <main.bicepparam> `                 # Optional
  -TemplateParameterObject <paramsHashTable> `               # Optional
  -BypassStackOutOfSyncError `                               # Optional
  -DenySettingsApplyToChildScope `                           # Optional
  -DenySettingsExcludedAction <actions> `                    # Optional
  -DenySettingsExcludedPrincipal <principalIDs> `            # Optional
  -Description <description> `                               # Optional. description of the Stack
  -Tag <tagHashTable>                                        # Optional

# Deployment Stacks at the Subscription scope
New-AzSubscriptionDeploymentStack `


# Deployment Stacks at the Management Group scope
New-AzManagementGroupDeploymentStack `

