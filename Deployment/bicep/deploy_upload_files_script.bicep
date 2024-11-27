@description('Specifies the location for resources.')
param solutionLocation string 
@secure()
param storageAccountKey string

param storageAccountName string

param containerName string
param identity string
param baseUrl string

// param azureOpenAIApiKey string
// param azureOpenAIEndpoint string
// param azureSearchAdminKey string
// param azureSearchServiceEndpoint string


// resource copy_demo_Data 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
//   kind:'AzureCLI'
//   name: 'copy_demo_Data'
//   location: solutionLocation // Replace with your desired location
//   identity:{
//     type:'UserAssigned'
//     userAssignedIdentities: {
//       '${identity}' : {}
//     }
//   }
//   properties: {
//     azCliVersion: '2.52.0'
//     primaryScriptUri: '${baseUrl}Deployment/scripts/copy_kb_files.sh' // deploy-azure-synapse-pipelines.sh
//     //arguments: '${storageAccountName} ${containerName} ${storageAccountKey} ${baseUrl} ${azureOpenAIApiKey} ${azureOpenAIEndpoint} ${azureSearchAdminKey} ${azureSearchServiceEndpoint}' // Specify any arguments for the script
//     timeout: 'PT1H' // Specify the desired timeout duration
//     retentionInterval: 'PT1H' // Specify the desired retention interval
//     cleanupPreference:'OnSuccess'
//   }
// }

// resource copy_demo_Data1 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
//   name: 'copy_demo_Data1'
//   location: solutionLocation
//   tags: {}
//   identity: {
//     type:'UserAssigned'
//     userAssignedIdentities: {
//       '${identity}' : {}
//     }
//   }
//   kind: 'AzurePowerShell'
//   properties: {
//     // storageAccountSettings: {
//     //   storageAccountName: '<storage-account-name>'
//     //   storageAccountKey: '<storage-account-key>'
//     // }
//     // containerSettings: {
//     //   containerGroupName: '<container-group-name>'
//     //   subnetIds: [
//     //     {
//     //       id: '<subnet-id>'
//     //     }
//     //   ]
//     // }
//     // environmentVariables: []
//     azPowerShellVersion: '10.0'
//     //arguments: '<script-arguments>'
//     primaryScriptUri: '${baseUrl}Deployment/scripts/copy_kb_files.ps1' // deploy-azure-synapse-pipelines.sh
//     //supportingScriptUris: []
//     timeout: 'PT1H'
//     cleanupPreference: 'OnSuccess'
//     retentionInterval: 'PT1H'
//     //forceUpdateTag: '1'
//   }
// }

resource copy_demo_Data1 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'copy_demo_Data1'
  location: solutionLocation
  tags: {}
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity}': {}
    }
  }
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.60.0' // Ensure compatibility with your script
    primaryScriptUri: '${baseUrl}Deployment/scripts/copy_kb_files.sh'
    arguments: '${baseUrl}'
    containerSettings: {
      imageName: 'mcr.microsoft.com/devcontainers/python:3.10-bullseye'
    }
    timeout: 'PT1H'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'PT1H'
  }
}


// resource copy_demo_Data1 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
//   name: 'copy_demo_Data1'
//   location: solutionLocation
//   tags: {}
//   identity: {
//     type: 'UserAssigned'
//     userAssignedIdentities: {
//       '${identity}': {}
//     }
//   }
//   kind: 'AzurePowerShell'
//   properties: {
//     azPowerShellVersion: '10.0'
//     primaryScriptUri: '${baseUrl}Deployment/scripts/copy_kb_files.ps1'
//     timeout: 'PT1H'
//     cleanupPreference: 'OnSuccess'
//     retentionInterval: 'PT1H'
//     containerSettings: {
//       osType: 'Windows'
//     }
//   }
// }
