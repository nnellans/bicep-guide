# For more information go to:
# https://www.nathannellans.com/post/deploying-bicep-files-part-6-scopes-stacks

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
# Will deploy to currently selected Subscription, change with: Set-AzContext -Subscription <subName>
New-AzSubscriptionDeploymentStack `
  -Name <name> `                                             # name of the Stack
  -ActionOnUnmanage deleteAll|deleteResources|detachAll `
  -DenySettingsMode denyDelete|denyWriteAndDelete|none `
  -Location <location> `                                     # location to store Deployment Stack metadata
  -DeploymentResourceGroupName <rgName> `                    # Optional. If deploying Stack to Sub and Bicep to RG
  -TemplateFile <main.bicep> `
  -TemplateParameterFile <main.bicepparam> `                 # Optional
  -TemplateParameterObject <paramsHashTable> `               # Optional
  -BypassStackOutOfSyncError `                               # Optional
  -DenySettingsApplyToChildScope `                           # Optional
  -DenySettingsExcludedAction <actions> `                    # Optional
  -DenySettingsExcludedPrincipal <principalIDs> `            # Optional
  -Description <description> `                               # Optional. description of the Stack
  -Tag <tagHashTable>                                        # Optional

# Deployment Stacks at the Management Group scope
New-AzManagementGroupDeploymentStack `
  -Name <name> `                                             # name of the Stack
  -ActionOnUnmanage deleteAll|deleteResources|detachAll `
  -DenySettingsMode denyDelete|denyWriteAndDelete|none `
  -Location <location> `                                     # location to store Deployment Stack metadata
  -ManagementGroupId <mgId> `                                # management group to deploy stack to
  -DeploymentSubscriptionId <subId> `                        # Optional. If deploying Stack to MG and Bicep to Sub
  -TemplateFile <main.bicep> `
  -TemplateParameterFile <main.bicepparam> `                 # Optional
  -TemplateParameterObject <paramsHashTable> `               # Optional
  -BypassStackOutOfSyncError `                               # Optional
  -DenySettingsApplyToChildScope `                           # Optional
  -DenySettingsExcludedAction <actions> `                    # Optional
  -DenySettingsExcludedPrincipal <principalIDs> `            # Optional
  -Description <description> `                               # Optional. description of the Stack
  -Tag <tagHashTable>                                        # Optional
