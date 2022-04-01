# Bicep File Structure
Here are the major sections of a bicep file. This is also the recommended order in which they should appear
1. targetScope
2. Parameters
3. Variables
4. Resources and/or Modules
5. Outputs

# 1. targetScope
You can only have 1 targetScope entry at the top of your file

It can be set to 1 of 4 options, all listed below

This specifies the level at which all of the resources in this Bicep file will be deployed 

This line is optional.  If you omit it, the default value of 'resourceGroup' is used

```bicep
targetScope = 'resourceGroup'
targetScope = 'subscription'
targetScope = 'managementGroup'
targetScope = 'tenant'
```

# 2. Parameters
Parameters are for values that will change/vary between different deployments

Each Parameter must be set to one of the supported Data Types (see below)

Optionally, you can use `=` to set a default value for the Parameter

The default value can use expressions, but it can NOT use the `reference` or `list` functions

```bicep
param myParameter1 string
param myParameter2 int
param myParameter3 string = 'default Value'
```

## Parameter Decorators
Decorators are placed directly above the parameter, you can use more than one decorator for each parameter

It's good practice to specify the min and max character length for parameters that control resource naming. These limitations help avoid errors later during deployment

For integers you can specify min and max values, instead

It's good practice to provide descriptions for all of your parameters. Try to make them helpful, and provide any important information about what the template needs the parameter values to be

The `@allowed()` decorator can be used to provide allowed values in an array. If the value doesn't match, then the deployment fails

```bicep
@minLength(1)
@maxLength(80)
@description('Provide a name for the VirtualWAN resource')
@allowed([
  'option1'
  'option2'
])
param myParameter4 string

@minValue(1)
@maxValue(20)
param myParameter5 int
```

## Bicep Data Types:
Bicep data types:  array, bool, int, object, secureObject, string, secureString

### Array
- Arrays use brackets:  `[ ]`
- Bicep does NOT support single-line arrays yet
- Do NOT use commas between values
- Each item is represented by the 'any' type, so you can have an array where each item is the same data type, or an array that holds different data types
- Bicep arrays are zero-based, so `exampleArrayParameter[0] = 'value1'`

```bicep
param exampleArrayParameter array = [
  'value1'
  'value2'
  'value3'
]
```

### Bool
- Simply use either true or false with no quotation marks

```bicep
param exampleBoolParameter bool = false
```

### Int
- A simple, whole number with no quotation marks
- In Bicep, these are 64-bit Integers
- Bicep does NOT support floating point, decimal, or binary yet

```bicep
param exampleIntParameter int = 1200
```

### Object
- Objects use braces / curly brackets:  `{ }`
- Bicep does NOT support single-line objects yet
- Do NOT use commas between properties
- Each property of the Object consists of a key and value separated by a colon
- Each property of the Object can be of any type
- Optionally, if the key contains special characters, you can enclose the key in single quotes
- You can use a period to access values, so `exampleObjectParameter.key2 = true`
- You can also use brackets to access values, so `exampleObjectParameter['key4'].keyA = 'value2'`

```bicep
param exampleObjectParameter object = {
  key1: 'value'
  key2: true
  'special.key3': 150
  key4: {
    keyA: 'value2'
  }
}
```

### String (single-line)
- Bicep uses single quotes for single-line strings
- All Unicode characters with code points between 0 and 10FFFF (both inclusive) are allowed

Escape Characters:
- Use `\\` for `\`
- Use `\'` for `'` (single quote)
- Use `\n` for line feed (LF)
- Use `\r` for carriage return (CR)
- Use `\t` for tab
- Use `\u{###}` for unicode characters
- Use `\$` for `$` (dollar sign) (this is only needed if you must type `${` and you're NOT using interpolation)

```bicep
param exampleStringParameter string = 'example string'
```

### String (multi-line)
- Opening sequence is `'''` (three single quotes)
- Closing sequence is `'''` (three single quotes)
- Everything in-between is read verbatim
- Escape characters are NOT not possible inside the string
- You can NOT include `'''` (three single quotes) inside your multi-line string
- Bicep does NOT support interpolation inside your multi-line string yet

```bicep
param exampleMultilineParameter string = '''
this
  is
    an
      idented
        example
'''
```

### secureObject and secureString
- Just add the `@secure()` decorator before your Object or String parameter
- The value is not saved to the deployment history and is not logged
- Make sure you use this in a location that expects a secure value, for example Tag values are stored in plain text, so do not use a secureString in a Tag
- Since these are secure, do NOT set a default value, as that will be stored in code

```bicep
@secure()
param exampleSecureObjectParameter object

@secure()
param exampleSecureStringParameter string
```

# 3. VARIABLES
Instead of embedding complex expressions directly into resource properties, use variables to contain the expressions

This approach makes your Bicep file easier to read and understand. It avoids cluttering your resource definitions with logic

Use camel case for variable names, such as `myVariableName`

When you define a variable, the data type isn't needed. Variables infer the type from the resolved value

The value of the variable can use all expressions, including the `reference` or `list` functions

```bicep
var myVariable1 = 'some value for the var'
```

# 4. RESOURCES
It's a good idea to use a recent API version for each resource. New features in Azure services are sometimes available only in newer API versions

When possible, avoid using the `reference` and `resourceId` functions in your Bicep file. You can access any resource in Bicep by using the symbolic name. By using the symbolic name, you create an implicit dependency between resources

You can still create explicit dependencies by using a `dependsOn` block, but see notes below about this

```bicep
resource myResource1 'Microsoft.Network/virtualWans@2021-02-01' = {
  name: 'resourceName'
  location: resourceGroup().location
  // Even though explicit dependencies are sometimes required, the need for them is rare. In most cases, you can use a symbolic name to imply the dependency between resources
  // If you find yourself setting explicit dependencies, you should consider if there's a way to remove it
  dependsOn: [
    myResource2
    myResource3
  ]
}
```

## Existing Resources:
To reference a resource that already exists, use the `existing` keyword in a resource declaration

How to define an existing resource in the same targetScope as the current deployment

```bicep
resource myResource2 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
  name: 'examplestorageaccount'
}
```

Optionally, you can set the `scope` property to access an existing resource in a different scope

```bicep
resource myResource3 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
  name: 'examplestorage'
  scope: resourceGroup(otherRG)
}
```

## Child Resources:
- Child resources are resources that exist only within the context of another resource
- Each 'parent' resource accepts only certain resource types as 'child' resources
- There are different ways you can declare a child resource

### Method 1. Child resource included within the Parent resource
- 'resourceType' for children can be the simple name `shares`, since the full resourceType path `Microsoft.Storage/storageAccounts/fileServices/shares` is assumed from the parent resource
- 'apiVersion' for children is optional, and if omitted the children will use the apiVersion of the parent resource
- 'name' for children can be the simple name `secondChildName`, since the full name `parentName/childName/secondChildName` is assumed from the parent resource
- Children can reference Parent resources with symbolic naming. But, Parents can NOT reference Child resources, this would cause a cyclic-dependency

```bicep
resource parentSymbolicName 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: 'parentName'
  propertiesOfParent
  propertiesOfParent

  resource childSymbolicName 'fileServices' = {
    name: 'childName'
    propertiesOfChild
    propertiesOfChild

    resource secondChildSymbolicName 'shares' = {
      name: 'secondChildName'
      propertiesOfSecondChild
    }
  }
}
```

### Method 2. The Child resources are defined separately in their own top-level resource
- The Child resource uses a `parent` parameter that points to the symbolic name of the parent resource
- Useful if the Child resources are deployed in a different Bicep file than the parent resources
- Useful if you want to use a loop on Child resources
- The 'resourceType' for children must be the full resourceType path `Microsoft.Storage/storageAccounts/fileServices/shares`
- The 'apiVersion' for children must be provided
- The 'name' for children can be just the simple name `childName`, since the full name `parentName/childName` is assumed from the parent resource

```bicep
resource childSymbolicName 'Microsoft.Storage/storageAccounts/fileServices@2021-04-01' = {
  parent: parentSymbolicName
  name: 'childName'
  propertiesOfChild
  propertiesOfChild
}
```

### Method 3. The Child resources are defined separately in their own top-level resource (same as above)
- But, the Child resource does NOT use a `parent` parameter
- The 'resourceType' for children must be the full resourceType path `Microsoft.Storage/storageAccounts/fileServices`
- The 'apiVersion' for children must be provided
- The 'name' for children must be the full name `parentName/childName`
- Dependencies are NOT inferred with this method, so you must include a `dependsOn` block and manually set dependencies as needed
- This method is NOT recommended

```bicep
resource secondChildSymbolicName 'Microsoft.Storage/storageAccounts/fileServices@2021-04-01' = {
  name: 'parentName/childName'
  propertiesOfChild
  propertiesOfChild

  dependsOn: [
    parentSymbolicName
  ]
}
```

## Extension Resources:
- An extension resource is meant to modify another resource
- A full list of extension resources can be [found here](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/extension-resource-types)

Example 1: By default, an extension resource will target what you have in your `targetScope` parameter

```bicep
resource myExtensionResource1 'Microsoft.Authorization/locks@2016-09-01' = {
  name: 'lockName'
  properties: {
    level: 'CanNotDelete'
  }
}
```

Example 2: This example sets the `targetScope` to `subscription`, so this extension resource will target a Subscription

```bicep
targetScope = 'subscription'
resource myExtensionResource2 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: 'roleAssignmentName'
  properties: {
    principalId: 'idOfPrincipal'
    roleDefinitionId: 'idOfRole'
  }
}
```

Example 3: Deploy an Extension Resource to a specific resource using the `scope` parameter
- This example creates a Role Assignment on the resource using the symbolic name 'myResource3'

```bicep
resource myExtensionResource3 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: 'roleAssignmentName'
  scope: myResource3
  properties: {
    principalId: 'idOfPrincipal'
    roleDefinitionId: 'idOfRole'
  }
}
```
# 4. MODULES
A module is just a Bicep file that is deployed from another Bicep file, allowing you to reuse code

The module (Bicep file) can be a local file or stored in a Registry

The `name` property is required. It becomes the name of the nested deployment resource in the generated ARM template

```bicep
module myModule1 '../someFile1.bicep' = {
  name: 'myModule1Deployment'
  params: {
    myModule1Param1: 'something'
    myModule1Param2: 'something'
    myModule1Param3: 'something'
  }
}
```

How to deploy a Module to a different scope using the `scope` parameter

This is important, this is how you can deploy resources to a scope that is different than your 'targetScope' parameter

```bicep
module myModule2 '../someFile2.bicep' = {
  name: 'myModule2Deployment'
  scope: 'anotherSubscription'
  params: {
    myModule2Param1: 'something'
    myModule2Param2: 'something'
    myModule2Param3: 'something'
  }
}
```

How to use a Module (Bicep file) in a Registry
- br: is the schema name for a Bicep Registry
- Optionally, you can configure Bicep Registry 'aliases' in your bicepconfig.json file and use the alias instead of the full registry path.  See this for [more info](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-config-modules)

```bicep
module myModule3 'br:exampleregistry.azurecr.io/bicep/modules/storage:v1' = {
}
```

How to conditionally deploy a Module

```bicep
module myModule4 '../someFile4.bicep' = if (condition) {
}
```

# 5. OUTPUTS
Use Outputs when you need to return certain values from a deployment

Make sure you don't create outputs for sensitive data. Output values can be accessed by anyone who has access to the deployment history. They're NOT appropriate for handling secrets

Instead of passing property values around through outputs, use the `existing` keyword to look up properties of resources that already exist. It's a best practice to look up keys from other resources in this way instead of passing them around through outputs. You'll always get the most up-to-date data

Outputs must set a specific data type

```bicep
output myOutput1 int = myResource4.properties.maxNumberOfRecordSets
```

If the property being returned has a hyphen in the name, you can NOT use the dot notation as shown above.  Instead, you must use brackets around the property

```bicep
output myOutput2 string = myResource1['some-property']
```

You can programmatically grab outputs from successful deployments

PowerShell:
```powershell
(Get-AzResourceGroupDeployment -ResourceGroupName <resourceGroupName> -Name <deploymentName>).Outputs.myOutput1.value
```

Azure CLI
```
az deployment group show -g <resourceGroupName> -n <deploymentName> --query properties.outputs.myOutput2.value
```

# Conditions (If)
You can deploy a resource only if a certain condition is met, otherwise the resource will not be deployed

```bicep
resource myResource4 'Microsoft.Network/dnszones@2018-05-01' = if (condition) {
  name: 'myZone'
  location: 'global'
}
```

Note 1:
- ARM evaluates the expressions used inside resource properties before it evaluates the conditional on the resource itself
- Example:
  - ResourceB is trying to reference the symbolicName of ResourceA
  - ResourceA has a condition where it will not be deployed
  - ResourceB's references to ResourceA are now invalid, and the deployment will fail with a 'ResourceNotFound' error
- Use the ternary operator as a workaround for this example

Note 2:
- You can't define two resources with the same name in the same Bicep file and then try to only deploy one of them based on a condition
- The deployment will fail, because Resource Manager views this as a conflict
- If you have several resources, all with the same condition for deployment, consider using Bicep Modules. You can create a Module that deploys all the resources, and then put a condition on the module declaration in your main Bicep file.

# Loops
To deploy more than one instance of an item, add the `for` expression

Loops are supported on: Variables, Resources, Modules, Properties, Outputs

Optionally, you can use the `batchSize` decorator to specify how many can be created at one time

Example 1: Integer Index

```bicep
@batchSize(int)
resource myResource5 'Microsoft.Storage/storageAccounts@2021-08-01' = [for i in range(int1,int2): {
  name:  'something-${i}'
}]
```

Example 2: Array elements

```bicep
@batchSize(int)
resource myResource6 'Microsoft.Storage/storageAccounts@2021-08-01' = [for item in array: {
  name: item.property1
}]
```

Example 3: Array and Index

```bicep
@batchSize(int)
resource myResource7 'Microsoft.Storage/storageAccounts@2021-08-01' = [for (item, i) in array: {
  name: 'something-${i}'
  location: item.property1
}]
```

Example 4: Complex Object / Dictionary

```bicep
@batchSize(int)
resource myResource8 'Microsoft.Storage/storageAccounts@2021-08-01' = [for item in items(object): {
  name: item.value.property1
}]
```

How to create a Resource with a loop and a condition

```bicep
@batchSize(int)
resource myResource9 'Microsoft.Storage/storageAccounts@2021-08-01' = [for item in array: if(item.property1 == true) {
  name: item.property2
}]
```

# Bicep Comments

```bicep
// This is a single-line comment

/*
This is a 
multi-line comment
*/
```

# Other

## Interpolation
- All strings in Bicep support interpolation
- To inject an expression surround it by `${` and `}`

```bicep
var lastName = 'Anderson'
var firstName = 'Thomas'
var fullName = '${lastName}, ${firstName}'
```

## Ternary Operator

```bicep
blah ? blah : blah
```

## Getting info from ARM Resource Provider

PowerShell
```powershell
((Get-AzResourceProvider -ProviderNamespace Microsoft.Batch).ResourceTypes | Where-Object ResourceTypeName -eq batchAccounts).Locations
```

Azure CLI
```
az provider show --namespace Microsoft.Batch --query "resourceTypes[?resourceType=='batchAccounts'].locations | [0]" --out table
```

# Links
- [Bicep Resource Reference](https://docs.microsoft.com/en-us/azure/templates/)
