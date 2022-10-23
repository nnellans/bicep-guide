Warning: This is not a beginner-friendly guide.  Think of this more like an advanced cheat sheet.  I went through most of the Microsoft Bicep documentation, as well as various books, and captured any notes that I felt were relevant or important.  Then, I organized them into the README file you see here.  Some of it is still a work in progress, and I will update this over time.

If you are new to Bicep, then I would suggest going through the Microsoft Docs or doing a couple Microsoft Learn courses first.

Here is a link to my own [Bicep Deployment Series](https://www.nathannellans.com/post/all-about-bicep-deploying-bicep-files) which goes over the various nuances of deploying Bicep files.

# Bicep Files & File Names
Bicep files use a `.bicep` file extension

If you are used to Terraform, you will see that Bicep works differently.  Terraform will combine every `.tf` file in the current directory and deploy all of them at the same time.  On the other hand, Bicep will deploy one main Bicep file per deployment.  It is suggested to name this file `main.bicep`

If you are storing parameters values in a separate parameters JSON file, it is common practice to use the name of the Bicep file and just add the word "parameters" like so:

```
Bicep file:      exampleFile.bicep
Parameter file:  exampleFile.parameters.json
```

# Bicep File Structure
Here are the major sections of a bicep file. This is also the recommended order in which they should appear
1. [targetScope](README.md#1-targetscope)
2. [Parameters](README.md#2-parameters)
3. [Variables](README.md#3-variables)
4. [Resources](README.md#4-resources) and/or [Modules](README.md#4-modules)
5. [Outputs](README.md#5-outputs)

# 1. targetScope
- You can only have 1 `targetScope` entry at the top of your file
- It can be set to 1 of 4 options, all listed below
- This specifies the level at which all of the resources in this Bicep file will be deployed (however, you can get around this by using Modules, more on that later)
- This line is optional.  If you omit it, the default value of `resourceGroup` is used

```bicep
targetScope = 'resourceGroup'
targetScope = 'subscription'
targetScope = 'managementGroup'
targetScope = 'tenant'
```

# 2. Parameters
- Parameters are for values that will change/vary between different deployments
- Each Parameter must be set to one of the supported Data Types (see below)
- Optionally, you can use `=` to set a default value for the Parameter
  - The default value can use expressions, but it can NOT use the `reference` or `list` functions

```bicep
// Defining Parameters
param myParameter1 string
param myParameter2 int
param myParameter3 string = 'default Value'

// Using Parameters
// Just use the name of the Parameter
resource exampleStorageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: myParameter1
  location: myParameter2
}
```

## Parameter Decorators
- Decorators are placed directly above the parameter definition
- You can use more than one decorator for each parameter definition
- It's good practice to specify the `minLength` and `maxLength` decorators for parameters that control resource naming. These limitations help avoid errors later during deployment
  - For integers you can specify `minValue` and `maxValue` decorators, instead
- It's good practice to provide the `description` decorator for all of your parameters. Try to make them helpful
- The `allowed` decorator can be used to provide allowed values in an array. If the value doesn't match, then the deployment fails
  - Use this sparingly, as Azure makes changes frequently to things like SKUs and sizes, so you don't want to have an allowed list that is out of date

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
Bicep data types include:  array, bool, int, object, string (plus secureObject and secureString)

### Array
- Arrays use square brackets:  `[ ]`
```bicep
// Bicep 0.6.18 and older support multi-line arrays only
// Use line breaks to separate values, no commas
param someName array = [
  'one'
  'two'
  'three'
]

// Bicep 0.7.4 and newer support single-line arrays
// Use commas to separate values
param someName array = [ 'one', 'two', 'three' ]

// Bicep 0.7.4 and newer also support multi-line arrays
// Use commas or line breaks to separate values
param someName array = [
  'one',
  'two',
  'three'
]
```
- A comma after the last value is supported, but not required
- The data types in an array do NOT have to match, as each item is represented by the 'any' type
- Bicep arrays are zero-based, so `exampleArrayParameter[0] = 'value1'`

### Bool
- Simply use either `true` or `false` with no quotation marks

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
```bicep
// Bicep 0.6.18 and older support multi-line objects only
// Use line breaks to separate pairs, no commas
param someName object = {
  key: 'value'
  key: 'value'
}

// Bicep 0.7.4 and newer support single-line objects
// Use commas to separate pairs
param someName object = { key: 'value', key: 'value' }

// Bicep 0.7.4 and newer also support multi-line objects
// Use commas or line breaks to separate pairs
param someName object = {
  key: 'value',
  key: 'value',
  key: 'value'
}
```
- A comma after the last pair is supported, but not required
- Each property of the Object can be of any type
- Optionally, if the key contains special characters, you can enclose the key in single quotes
- You can use a period to access values, so `exampleObjectParameter.key2 = true`
- You can also use brackets to access values, so `exampleObjectParameter['key4'].keyA = 'value2'`
- Complex object example:
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
- Escape Characters:
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
- Make sure you use this parameter in a location that expects a secure value, for example Tag values are stored in plain text, so do not use a secureString parameter in a Tag
- Since these are secure, do NOT set a default value, as that will be stored in code

```bicep
@secure()
param exampleSecureObjectParameter object

@secure()
param exampleSecureStringParameter string
```

# 3. Variables
- Instead of embedding complex expressions directly into resource properties, use variables to contain the expressions
- This approach makes your Bicep file easier to read and understand. It avoids cluttering your resource definitions with logic
- When you define a variable, the data type isn't needed. Variables infer the type from the resolved value
- The value of the variable can use all available expressions, including the `reference` or `list` functions

```bicep
// Defining Variables
var myVariable1 = 'some value for the var'

// Using Variables
// Just use the name of the Variable
resource exampleStorageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: myVariable1
}
```

# 4. Resources
- It's a good idea to use a recent API version for each resource. New features in Azure services are sometimes available only in newer API versions
- When possible, avoid using the `reference` and `resourceId` functions in your Bicep file. You can access any resource in Bicep by using the symbolic name. By using the symbolic name, you create an implicit dependency between resources
- You can still create explicit dependencies by using a `dependsOn` block, but see notes below about this

```bicep
resource myResource1 'Microsoft.Network/virtualWans@2021-02-01' = {
  name: 'resourceName'
  location: 'location'

  // Even though explicit dependencies are sometimes required, the need for them is rare
  // In most cases, you can use a symbolic name to imply the dependency between resources
  // If you are setting explicit dependencies, you should consider if there's a way to remove it
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
- Each 'parent' resource accepts only certain 'child' resources.  Check out the [Bicep Resource Reference](https://docs.microsoft.com/en-us/azure/templates/) for the supported parent/child relationships.
- There are different ways you can declare a child resource:

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
- Benefit over Method 1: allows you to define the Child resources in a different Bicep file than the Parent resources
- Benefit over Method 1: allows you to use a loop on Child resources
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
- At first glance, this looks the same as Method 2.  But, with Method 3 the Child resource does NOT use a `parent` parameter
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
- This example creates a Role Assignment on the resource which has the symbolic name 'myResource3'

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
# 4. Modules
- A module is just a Bicep file that is deployed from another Bicep file, allowing you to reuse code
- The module (Bicep file) can be a local file or stored in a Registry
- The `name` property is required. It becomes the name of the nested deployment resource in the generated ARM template

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
> This is important, this is how you can deploy resources to a scope that is different than your 'targetScope' parameter

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
- `br:` is the schema name for a Bicep Registry
- Optionally, you can configure Bicep Registry 'aliases' in your `bicepconfig.json` file and use the alias instead of the full registry path.  See this for [more info](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-config-modules)
  - Starting with Bicep v0.5.6 there is a default alias called `public` which points at Microsoft's official registry of Bicep modules.
  - An example would be:  `br/public:network/virtual-network:1.0`
  - [Here is a link](https://github.com/Azure/bicep-registry-modules) to the official GitHub repo containing the current listing of modules.  Microsoft admits the registry is fairly barebones right now, as they are just getting started at the time of this writing.

```bicep
module myModule3 'br:exampleregistry.azurecr.io/bicep/modules/storage:v1' = {
```

# 5. Outputs
- Use Outputs when you need to return certain values from a deployment
- Make sure you don't create outputs for sensitive data. Output values can be accessed by anyone who can view the deployment history. They're NOT appropriate for handling secrets
- Instead of passing property values around through outputs, use the `existing` keyword to look up properties of resources that already exist. It's a best practice to look up keys from other resources in this way instead of passing them around through outputs. You'll always get the most up-to-date data
- Outputs must set a specific data type

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
(Get-AzResourceGroupDeployment -ResourceGroupName <rgName> -Name <deploymentName>).Outputs.myOutput1.value
```

Azure CLI:
```
az deployment group show -g <rgName> -n <deploymentName> --query properties.outputs.myOutput2.value
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
  - ResourceB has properties which are referencing the symbolicName of ResourceA
  - ResourceA has a condition where it will not be deployed
  - ResourceB's references to ResourceA are now invalid, and the deployment will fail with a 'ResourceNotFound' error
  - This will fail even if ResourceB has the same condition applied to it as ResourceA
- Use the ternary operator on the properties of ResourceB as a workaround

Note 2:
- You can't define two resources with the same name in the same Bicep file and then use a condition to only deploy one of them
- The deployment will fail, because Resource Manager views this as a conflict
- If you have several resources, all with the same condition for deployment, consider using Bicep Modules. You can create a Module that deploys all the resources, and then put a condition on the module declaration in your main Bicep file.

# Loops
- To deploy more than one instance of an item, add the `for` expression
- Loops are supported on: Variables, Resources, Modules, Properties, Outputs
- Optionally, you can use the `@batchSize()` decorator to specify how many can be created at one time

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

The ternary operator is a way to embed an if/then/else statement inside the properties of a resource.

```bicep
condition ? valueIfTrue : valueIfFalse
```

The true or false values can be of any data type: string, integer, boolean, object, array

## Functions

Bicep has a large assortment of functions that can be used in your template.  Check out the [officials docs](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions) for more information about all of the available Functions and their instructions.

## Lambda Expressions
Lambda Expressions are supported starting with Bicep v0.10.61.  Lambda Expressions can only be used as arguments on 4 specific functions: filter, map, reduce, and sort.  The general format of a Lambda Expression is `lambdaVariable => lambdaExpression`.  [Read the docs](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions-lambda) for more information and examples for Lamba Expressions.

```bicep
// 1. filter
// this filters an input array with a custom filtering function
// the lambda expression is applied to each element of the input array. If the expression is false, the item will be filtered out of the output array
filter(inputArray, lambdaExpression)

// 2. map
// this applies a custom mapping function to each element of the input array
// the lambda expression is applied to each element of the input array in order to generate the output array. This could be pulling out just one value, doing string interpolation, or any other modification you want
map(inputArray, lambdaExpression)

// 3. reduce
// this reduces an input array with a custom reduce function
// the lambda expression is used to aggregate the current value and the next value
reduce(inputArray, initialValue, lambdaExpression)

// 4. sort
// this sorts an input array with a custom sort function
// the lambda expression is used to compare two input array elements for ordering. If true, the second element will be ordered after the first in the output array
sort(inputArray, lambdaExpression)
```

## Templates for Deploying Bicep

I've written a whole series of articles describing the different methods that can be used to deploy Bicep:
- [Deploying with Az CLI](https://www.nathannellans.com/post/deploying-bicep-files-part-2-az-cli)
- [Deploying with Az PowerShell Module](https://www.nathannellans.com/post/deploying-bicep-files-part-3-az-powershell-module)
- [Deploying with Azure DevOps Pipelines](https://www.nathannellans.com/post/deploying-bicep-files-part-4-azure-devops-pipelines)

I've also included some example files in this repo:
- [Az CLI examples](./deployment-options/az-cli.sh)
- [Az PowerShell Module examples](./deployment-options/az-powershell-module.ps1)
- [Azure DevOps Pipelines examples](./deployment-options/azure-devops-pipelines.yml)

## Examples of getting info from ARM Resource Provider (WIP)

PowerShell:
```powershell
((Get-AzResourceProvider -ProviderNamespace Microsoft.Batch).ResourceTypes | Where-Object ResourceTypeName -eq batchAccounts).Locations
```

Azure CLI:
```
az provider show --namespace Microsoft.Batch --query "resourceTypes[?resourceType=='batchAccounts'].locations | [0]" --out table
```

# Links
- [Bicep Resource Reference](https://docs.microsoft.com/en-us/azure/templates/)
- [Understand the structure and syntax of Bicep files](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/file)
- [Bicep Best Practices](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/best-practices)
- [Bicep Functions](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions)
- [Bicep Operators](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/operators)
