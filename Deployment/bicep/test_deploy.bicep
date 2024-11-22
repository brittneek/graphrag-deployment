@description('The location of the resources.')
param location string = resourceGroup().location

@description('The storage account to list blobs from.')
// param storageAccountData {
//   name: string
//   container: string
// }
param storageAccountDataName string 
param storageAccountDataContainer string

@description('The role id of Storage Blob Data Reader.')
var storageBlobDataReaderRoleId = '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'

@description('The storage account to read blobs from.')
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-04-01' existing = {
  //name: storageAccountData.name
  name: storageAccountDataName
}

@description('The Storage Blob Data Reader Role definition from [Built In Roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles).')
resource storageBlobDataReaderRoleDef 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  scope: subscription()
  name: storageBlobDataReaderRoleId
}

@description('The user identity for the deployment script.')
resource scriptIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: 'script-identity'
  location: location
}

@description('Assign permission for the deployment scripts user identity access to the read blobs from the storage account.')
resource dataReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageAccount
  name: guid(storageBlobDataReaderRoleDef.id, scriptIdentity.id, storageAccount.id)
  properties: {
    principalType: 'ServicePrincipal'
    principalId: scriptIdentity.properties.principalId
    roleDefinitionId: storageBlobDataReaderRoleDef.id
  }
}

@description('The deployment script.')
resource script 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'script'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${scriptIdentity.id}': {}
    }
  }
  properties: {
    azCliVersion: '2.59.0'
    retentionInterval: 'PT1H'
    arguments: '${storageAccount.properties.primaryEndpoints.blob} ${storageAccountDataContainer}'
    scriptContent: '''
      #!/bin/bash
      # Define variables
      VENV_DIR="venv"  # Virtual environment directory name
      REQUIREMENTS_FILE="graphrag-requirements.txt"  # Requirements file
      PYTHON_VERSION="python3.10"  # Python version

      echo "Setting up a Python 3.10 virtual environment..."

      # Check if Python 3.10 is installed
      if ! command -v $PYTHON_VERSION &> /dev/null; then
          echo "Python 3.10 not found. Installing..."
          sudo apt update
          sudo apt install -y software-properties-common
          sudo add-apt-repository -y ppa:deadsnakes/ppa
          sudo apt update
          sudo apt install -y python3.10 python3.10-venv python3.10-distutils

          if ! command -v $PYTHON_VERSION &> /dev/null; then
              echo "Error: Python 3.10 installation failed."
              exit 1
          fi
          echo "Python 3.10 installed successfully."
      fi

      # Create virtual environment with Python 3.10
      if [ ! -d "$VENV_DIR" ]; then
          echo "Creating virtual environment in $VENV_DIR..."
          echo "$PYTHON_VERSION -m venv $VENV_DIR --copies"
          $PYTHON_VERSION -m venv $VENV_DIR --copies
          echo "Virtual environment created successfully."
      else
          echo "Virtual environment already exists. Skipping creation."
      fi

      # Activate the virtual environment
      echo "Activating the virtual environment..."
      source $VENV_DIR/bin/activate
    '''
  }
}
