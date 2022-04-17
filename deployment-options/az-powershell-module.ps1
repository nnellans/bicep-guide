# For more information go to:
# https://www.nathannellans.com/post/deploying-bicep-files-part-3-az-powershell-module

# Install the Az Module from PowerShell Gallery
Install-Module -Name Az

# Deploy Bicep to a Resource Group
New-AzResourceGroupDeployment `
  -ResourceGroupName <rgName> `
  -Mode Incremental | Complete `                                  # Optional, choose one. Default: Incremental
  -RollbackToLastDeployment | -RollbackToDeployment <name> `      # Optional, choose one
  -Name <deploymentName> `                                        # Optional. Default: name of the Bicep file
  -TemplateFile <template.bicep> `
  -TemplateParameterFile <template.parameters.json> `             # Optional
  -Key1 Value1 -Key2 Value2 `                                     # Optional parameter overrides
  -WhatIf | -Confirm | -Confirm -ProceedIfNoChange                # Optional, choose one

# Deploy Bicep to a Subscription
New-AzDeployment `
  -Location <region> `
  -Name <deploymentName> `                                        # Optional. Default: name of the Bicep file
  -TemplateFile <template.bicep> `
  -TemplateParameterFile <template.parameters.json> `             # Optional
  -Key1 Value1 -Key2 Value2 `                                     # Optional parameter overrides
  -WhatIf | -Confirm | -Confirm -ProceedIfNoChange                # Optional, choose one

# Deploy Bicep to a Management Group
New-AzManagementGroupDeployment `
  -Location <region> `
  -ManagementGroupId <mgId> `
  -Name <deploymentName> `                                        # Optional. Default: name of the Bicep file
  -TemplateFile <template.bicep> `
  -TemplateParameterFile <template.parameters.json> `             # Optional
  -Key1 Value1 -Key2 Value2 `                                     # Optional parameter overrides
  -WhatIf | -Confirm | -Confirm -ProceedIfNoChange                # Optional, choose one

# Deploy Bicep to a Tenant
New-AzTenantDeployment `
  -Location <region> `
  -Name <deploymentName> `                                        # Optional. Default: name of the Bicep file
  -TemplateFile <template.bicep> `
  -TemplateParameterFile <template.parameters.json> `             # Optional
  -Key1 Value1 -Key2 Value2 `                                     # Optional parameter overrides
  -WhatIf | -Confirm | -Confirm -ProceedIfNoChange                # Optional, choose one
