# Bicep Guide

- Version: 1.1.0
- Author:
  - Nathan Nellans
  - Email: me@nathannellans.com
  - Web:
    - https://www.nathannellans.com
    - https://github.com/nnellans/bicep-guide


> [!IMPORTANT]
> This is an advanced guide and assumes you already know the basics of Bicep.  Think of this more like an advanced cheat sheet.  I went through various sources, captured any notes that I felt were important, and organized them into the README file you see here.  If you are new to Bicep, then I would suggest going through the Microsoft Docs or doing a couple Microsoft Learn courses first.

> [!WARNING]
> This is a live document.  Some of the sections are still a work in progress.  I will be continually updating it over time.

> [!NOTE]
> Here is a link to my own [Bicep Deployment Series](https://www.nathannellans.com/post/all-about-bicep-deploying-bicep-files) which goes over the various nuances of deploying Bicep files.

---

# Bicep Files & File Names
Bicep files use a `.bicep` file extension and are written using their own custom domain-specific language (DSL).

If you're accustomed to Terraform, you will see that Bicep works differently when it comes to deploying code.  Terraform will combine every `.tf` file in the current directory and deploy them all at the same time.  Whereas Bicep will deploy one main `.bicep` file per deployment.  It is suggested to name this file `main.bicep`

If you are storing parameters values in a separate parameters JSON file, it is common practice to use the name of the Bicep file and just add the word "parameters" like shown below.  If you are using the newer Bicep parameter format, then just use the name of the Bicep file with the extension of `.bicepparam`.  Support for `.bicepparam` files requires Bicep v0.18.4 or later.

```
Bicep file:           main.bicep
JSON Parameter file:  main.parameters.json
Bicep Parameter file: main.bicepparam
```

# Bicep File Structure
Here are the major sections of a bicep file. This is also the recommended order in which they should appear
1. [metadata](README.md#1-metadata)
2. [targetScope](README.md#2-targetscope)
3. [Parameters](README.md#3-parameters)
4. [Variables](README.md#4-variables)
5. [Resources](README.md#5-resources) and/or [Modules](README.md#5-modules)
6. [Outputs](README.md#6-outputs)

---

# 1. Metadata
- These are simple key/value pairs that can contain any information you want to include
- Some good examples are a description, author, creation date, etc.
- These are optional

```bicep
metadata description = 'This file deploys 12 resources'
metadata author = 'me@nathannellans.com'
```

---

# 2. targetScope
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

---

# 3. Parameters
- Parameters are for values that will change/vary between different deployments
- Each Parameter must be set to one of the supported Data Types (see below)
- Optionally, you can use `=` to set a default value for the Parameter
  - The default value can use expressions, but it can NOT use the `reference` or `list` functions

```bicep
// Defining Parameters
param myParameter1 int
param myParameter2 array
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
- It's good practice to specify the `description` decorator for all of your parameters. Try to make them helpful
- The `allowed` decorator can be used to provide allowed values in an array. If the value doesn't match, then the deployment fails
  - Use this sparingly, as Azure makes changes frequently to things like SKUs and sizes, so you don't want to have an allowed list that is out of date
- The `metadata` decorator is an object that can contain properties of any name and type. Use this for info that you don't want to put into the `description` decorator

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
@metadata({
  key1: 'value1'
  key2: 'value2'
})
param myParameter5 int
```

## Bicep Data Types:
Bicep data types include:  array, bool, int, object, string (plus secureObject and secureString)

### Array
- Arrays use square brackets:  `[ ]`
```bicep
// Multi-line arrays (use line breaks to separate values)
param someName array = [
  'one'
  'two'
  'three'
]

// Single-line arrays (use commas to separate values)
// Requires Bicep 0.7.4 or newer
param someName array = [ 'one', 'two', 'three' ]
```
- In single-line, a comma after the last value is supported, but not required
- The data types in an array do NOT have to match, as each item is represented by the 'any' type
- Bicep arrays are zero-based, so using the example above `someName[0] = 'one'`

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
// Multi-line objects (use line breaks to separate pairs)
param someName object = {
  key: 'value'
  key: 'value'
}

// Single-line objects (use commas to separate pairs)
// Requires Bicep 0.7.4 or newer
param someName object = { key: 'value', key: 'value' }
```
- For single-line, a comma after the last pair is supported, but not required
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

### Custom User-Defined Types
- Starting with Bicep v0.21.1, you can create your own user-defined types

```bicep
// This custom type defines a string, and sets 3 allowed values
type myCustomType1 = 'azure' | 'gcp' | 'aws'

// To define an array put [] at the end
// This custom type defines an array of strings
type myCustomType2 = string[]

// This custom type defines an array of strings, and only allows certain values in the array
type myCustomType3 = ('one' | 'two' | 'three')[]

// This custom type defines an object of mixed types
type myCustomType4 = {
  name: string
  age: int
  gender: string?  // The ? at the end marks this as optional
}

// Then, in your parameter, use this custom type instead of the standard types like `string`, `bool`, etc.
param someParamName myCustomType3

// Option 2, simply define the custom type inline in your parameter (this defines an array of objects)
param someParamName {
  name: string
  age: int
}[]
```

---

# 4. Variables
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

---

# 5. Resources
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

---

# 5. Modules
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
> [!NOTE]
> This is how you can deploy resources to a scope that is different than your 'targetScope' parameter

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

---

# 6. Outputs
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

---

# Other Topics

- [Parameter Files](README.md#parameter-files)
- [Conditions (If)](README.md#conditions-if)
- [Loops](README.md#loops)
- Miscellaneous
  - [Comments](README.md#comments)
  - [String Interpolation](README.md#string-interpolation)
  - [Ternary Operator](README.md#ternary-operator)
  - [Functions](README.md#functions)
  - [Import / Export](README.md#import--export)

---

# Parameter Files

Instead of storing parameter values directly in your `.bicep` file, you can store the values externally in a `.bicepparam` or `.json` file.  Then, you'd pass this parameter file, along with the `.bicep` file, to your deployment.

> [!NOTE]
> This guide is only going to cover the newer `.bicepparam` files.  If you'd like to know more about the older `.json` parameter files, then please reference [the documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/parameter-files).

Format of a `.bicepparam file`
```bicep
// the using statement
using 'something'

// optional variables
var varName1 = value1
var varName2 = value2

// parameter values
param parName1 = value1
param parName2 = readEnvironmentVariable('someEnvVar')
param parName3 = toLower(value3)
param parName4 = az.getSecret('subscriptionId', 'resourceGroupName', 'keyvaultName', 'secretName', 'secretVersion')
```

Each `.bicepparam` file is tied to a particular `.bicep` file.  This relationship is defined by the `using` statement.  There are multiple options for defining the `using` statement, see below for more.
- Support for ARM Templates, Bicep Registries, and Template Specs was added in Bicep v0.22.6

```bicep
// a regular bicep file or arm template
using 'path/to/file.bicep'
using 'path/to/file.json'

// a module from the public bicep registry
using 'br/public:path:tag'

// a module from a private bicep registry
using 'br:registryName.azurecr.io/bicep/path:tag'
using 'br/aliasName:path:tag'

// a template spec
using 'ts:subscriptionId/resourceGroupName/specName:tag'
using 'ts/aliasName:specName:tag'

// NOT tied to anything
using none
```

Starting with Bicep v0.21.1 you can define optional Variables in your `.bicepparam` files.

You can use expressions in the value of each parameter.
- Use the `readEnvironmentVariable` function to pull a value from an environment variable.
- Don't store sensitive values in your parameter files.  Instead, use the `az.getSecret` function to pull the value from Key Vault.
  - The `az.getSecret` function can only pull secrets from Key Vault.
  - The `az.getSecret` function can only be used in a `param` value
  - The `az.getSecret` function only supports params that have the `@secure()` decorator
  - By default, it will pull the latest version of the secret, unless you specify the `secretVersion` parameter

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

---

# Miscellaneous

## Comments

```bicep
// This is a single-line comment

/*
This is a 
multi-line comment
*/
```

## String Interpolation
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

### User-defined Functions
- Support for User-defined Functions requires Bicep v0.26.54 or later
- Allows you to create and use your own custom functions within a Bicep file
- Great for when you have complicated expressions that are used repeatedly in your Bicep files
- They can be nested, you can call a User-defined Function from another User-defined function
- They support custom User-defined Data Types
- Some limitations:
  - Can't access variables
  - Can only use parameters that are defined in the function
    - Parameters defined in the function can't have default values
  - Can't use the `reference` or `list` functions
- [Read the docs](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/user-defined-functions) for more information on User-defined Functions

```bicep
// create a user-defined function
func functionName (argName dataType, argName dataType, ...) functionDataType => expression

// first, define the functionName that you want to give to this user-defined function
// then, define any arguments that the function uses, specify a name and a data type for each argument
// then, define the data type of the function's return value
// finally, define what value the function will return by creating a custom expression that uses the arguments
```

### Lambda Expressions
- Lambda Expressions can only be used as arguments on the following specific functions:
  - `filter()`, `map()`, `reduce()`, `sort()` - Supported with Bicep v0.10.61 onward
  - `toObject()` - Supported with Bicep v0.14.6 onward
  - `groupBy()`, `mapValues()` - Supported with Bicep v0.27.1 onward
- The general format of a Lambda Expression is `lambdaVariable => lambdaExpression`.
- [Read the docs](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions-lambda) for more information and examples for Lamba Expressions.

Example: `filter()`

```bicep
filter(inputArray, lambdaExpression)
// input: array
// lambaExpression: expression/test to run against each element of the array
//   - Supports an optional index as of Bicep v0.27.1
// output: array (containing only elements that passed the test)

// example
var inputArray = [
  {
    name: 'Reba'
    age: 24
  }
  {
    name: 'Garth'
    age: 10
  }
]

output someOutput array = filter(inputArray, item => item.age > 15)
// This returns only elements of the array that have an age value greater than 15,
someOutput = [
  {
    name: 'Reba'
    age: 24
  }
]
```

Example: `groupBy()`

```bicep
groupBy(inputArray, lambdaExpression)
// input: array
// lambdaExpression: the expression used to group the array elements 
// output: object (containing the grouped elements)

//example
var inputArray = ['Reba', 'Rodney', 'Garth', 'Gary']

output someOutput object = groupBy(inputArray, item => substring(item, 0, 1))
// This returns an object which groups the array elements by their first character
someOutput = {
  R: ['Reba', 'Rodney']
  G: ['Garth', 'Gary']
}
```

Example: `map()`

```bicep
map(inputArray, lambdaExpression)
// input: array
// lambaExpression: whatever manipulation you want
//   - Supports an optional index as of Bicep v0.27.1
// output: array (containing your manipulated elements)

// example
var inputArray = [
  {
    name: 'Reba'
    age: 24
  }
  {
    name: 'Garth'
    age: 10
  }
]

output someOutput1 array = map(inputArray, item => item.name)
// This returns an array containing just the values of each name:
someOutput1 = [
  'Reba'
  'Garth'
]

output someOutput2 array = map(inputArray, item => 'Hello ${item.name}!')
// This returns an array which concatenates text to each name:
someOutput2 = [
  'Hello Reba!'
  'Hello Garth!'
]
```

Example: `mapValues()`

```bicep
mapValues(inputObject, lambdaExpression)
// input: object
// lambdaExpression: the expression used to modify each value
// output: object (containing modified values)

// example
var inputObject = {
  something: 'foo'
  anotherthing: 'bar'
}

output someOutput object = mapValues(inputObject, item => toUpper(item))
// This returns the same object, but with modified values. In this case, the values are converted to uppercase:
someOutput = {
  something: 'FOO'
  anotherthing: 'BAR'
}
```

Example: `reduce()`

```bicep
reduce(inputArray, initialValue, lambdaExpression)
// input: array
// initialValue: the initial starting value for comparison
// lambdaExpression: expression used to aggregate the current value with the next value
//   - Supports an optional index as of Bicep v0.27.1
// output: any

var inputArray = [5, 3, 2, 8]

output someOutput int = reduce(inputArray, 0, (currentItem, nextItem) => currentItem + nextItem)
// This returns an integer which is the result of adding each item in the array to the next item, starting with 0
// For example: ((((0 + 5) + 3) + 2) + 8)
someOutput = 18
```

Example: `sort()`

```bicep
sort(inputArray, lambdaExpression)
// input: array
// lambdaExpression: an expression that compares one array element to another
// output: array (elements are sorted per your expression)

// example
var inputArray = [
  {
    name: 'Reba'
    age: 24
  }
  {
    name: 'Garth'
    age: 10
  }
  {
    name: 'Toby'
    age: 2
  }
]

output someOutput array = sort(inputArray, (item1, item2) => item1.age < item2.age)
// This returns an array with the exact same elements, however they are sorted by age, lowest to highest
someOutput = [
  {
    name: 'Toby'
    age: 2
  }
  {
    name: 'Garth'
    age: 10
  }
  {
    name: 'Reba'
    age: 24
  }
]
```

Example: `toObject()`

```bicep
toObject(inputArray, lambdaExpression, [lambdaExpression])
// input: array
// lambdaExpression: defines the key of each element for the output object
// optional lambdaExpression: defines the value of each element for the output object
// output: object

// example
var inputArray = [
  {
    name: 'Reba'
    age: 24
  }
  {
    name: 'Garth'
    age: 10
  }
]

output someOutput1 object = toObject(inputArray, item => item.name)
// This creates a dictionary object, where the key of each element is the 'name'
// Since the optional 2nd lambdaExpression was omitted, then the value becomes the original array element
someOutput1 = {
  Reba: {
    name: 'Reba'
    age: 24
  }
  Garth: {
    name: 'Garth'
    age: 10
  }
}

output someOutput2 object = toObject(inputArray, item => item.name, item => item.age)
// This creates a dictionary object, where the key of each element is the 'name' and the value of each one is 'age'
// This example includes the optional 2nd lambaExpression, and we get a return value like this:
someOutput2 = {
  Reba: 24
  Garth: 10
}
```

### Import / Export
- First, you can specify the `@export()` decorator on any User-defined Type (`type`), User-defined Function (`func`), or Variable (`var`).  This marks the item as being exportable.
- Then, you can use the `import` function, in a totally different Bicep file, to import that `type`, `func`, or `var` from the first Bicep file.
- Support for Compile-time Imports is generally available as of Bicep v0.25.3

Example `exports.bicep` file:
```bicep
@export()
type myUserDefinedType = {
  something: string
  anotherthing: int
}

@export()
func myUserDefinedFunction(name string) string => 'Hey there ${name}'

@export()
var myVariable = 'some constant value'
// can only use constant values, or references to other variables
// can not use references to resources, modules, or parameters
```

Example `main.bicep` file:
```bicep
// method 1, import the given items from exports.bicep
import {myUserDefinedType, myVariable} from 'exports.bicep'

// method 1, same as above, but define an optional alias that you can use
import {myVariable as newVariableAlias} from 'exports.bicep'

// method 2, import everything from exports.bicep into the symbolic name allImports
// then reference each item like so:  allImports.myUserDefinedType, allImports.myUserDefinedFunction, allImports.myVariable
import * as allImports from 'exports.bicep'
```

Support for `.bicepparam` files
- As of Bicep v0.22.6, you can import Variables in your `.bicepparam` files
- As of Bicep v0.26.54, you can import User-defined Functions in your `.bicepparam` files

---

## Examples of getting info from ARM Resource Provider (WIP)

PowerShell:
```powershell
((Get-AzResourceProvider -ProviderNamespace Microsoft.Batch).ResourceTypes | Where-Object ResourceTypeName -eq batchAccounts).Locations
```

Azure CLI:
```
az provider show --namespace Microsoft.Batch --query "resourceTypes[?resourceType=='batchAccounts'].locations | [0]" --out table
```

---

## Templates for Deploying Bicep

I've written a whole series of articles describing the different methods that can be used to deploy Bicep:
- [Deploying with Az CLI](https://www.nathannellans.com/post/deploying-bicep-files-part-2-az-cli)
- [Deploying with Az PowerShell Module](https://www.nathannellans.com/post/deploying-bicep-files-part-3-az-powershell-module)
- [Deploying with Azure DevOps Pipelines](https://www.nathannellans.com/post/deploying-bicep-files-part-4-azure-devops-pipelines)
- [Deploying with GitHub Actions](https://www.nathannellans.com/post/deploying-bicep-files-part-5-github-actions)

I've also included some example files in this repo:
- [Az CLI examples](./deployment-options/az-cli.sh)
- [Az PowerShell Module examples](./deployment-options/az-powershell-module.ps1)
- [Azure DevOps Pipelines examples](./deployment-options/azure-devops-pipelines.yml)
- [GitHub Actions examples](./deployment-options/github-actions.yml)

---

# Links
- [Bicep Resource Reference](https://docs.microsoft.com/en-us/azure/templates/)
- [Understand the structure and syntax of Bicep files](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/file)
- [Bicep Best Practices](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/best-practices)
- [Bicep Functions](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions)
- [Bicep Operators](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/operators)
