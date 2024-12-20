// ========== main.bicep ========== //
targetScope = 'resourceGroup'

@minLength(3)
@maxLength(6)
@description('Prefix Name')
param solutionPrefix string

@description('other Location')
param otherLocation string

// @description('Fabric Workspace Id if you have one, else leave it empty. ')
// param fabricWorkspaceId string

var resourceGroupLocation = resourceGroup().location
var resourceGroupName = resourceGroup().name
// var subscriptionId  = subscription().subscriptionId

var solutionLocation = resourceGroupLocation
// var baseUrl = 'https://raw.githubusercontent.com/microsoft/Build-your-own-copilot-Solution-Accelerator/main/ClientAdvisor/'
var baseUrl = 'https://raw.githubusercontent.com/brittneek/graphrag-deployment/main/'




// ========== Managed Identity ========== //
module managedIdentityModule 'deploy_managed_identity.bicep' = {
  name: 'deploy_managed_identity'
  params: {
    solutionName: solutionPrefix
    solutionLocation: solutionLocation
  }
  scope: resourceGroup(resourceGroup().name)
}

// module cosmosDBModule 'deploy_cosmos_db.bicep' = {
//   name: 'deploy_cosmos_db'
//   params: {
//     solutionName: solutionPrefix
//     solutionLocation: cosmosLocation
//     identity:managedIdentityModule.outputs.managedIdentityOutput.objectId
//   }
//   scope: resourceGroup(resourceGroup().name)
// }


// ========== Storage Account Module ========== //
module storageAccountModule 'deploy_storage_account.bicep' = {
  name: 'deploy_storage_account'
  params: {
    solutionName: solutionPrefix
    solutionLocation: solutionLocation
    managedIdentityObjectId:managedIdentityModule.outputs.managedIdentityOutput.objectId
  }
  scope: resourceGroup(resourceGroup().name)
}

// //========== SQL DB Module ========== //
// module sqlDBModule 'deploy_sql_db.bicep' = {
//   name: 'deploy_sql_db'
//   params: {
//     solutionName: solutionPrefix
//     solutionLocation: otherLocation
//     managedIdentityObjectId:managedIdentityModule.outputs.managedIdentityOutput.objectId
//   }
//   scope: resourceGroup(resourceGroup().name)
// }

// // ========== Azure AI services multi-service account ========== //
// module azAIMultiServiceAccount 'deploy_azure_ai_service.bicep' = {
//   name: 'deploy_azure_ai_service'
//   params: {
//     solutionName: solutionPrefix
//     solutionLocation: solutionLocation
//   }
// } 

// // ========== Search service ========== //
// module azSearchService 'deploy_ai_search_service.bicep' = {
//   name: 'deploy_ai_search_service'
//   params: {
//     solutionName: solutionPrefix
//     solutionLocation: solutionLocation
//   }
// } 

// // ========== Azure OpenAI ========== //
// module azOpenAI 'deploy_azure_open_ai.bicep' = {
//   name: 'deploy_azure_open_ai'
//   params: {
//     solutionName: solutionPrefix
//     solutionLocation: resourceGroupLocation
//   }
// }

module uploadFilesO 'deploy_upload_files_script.bicep' = {
  name : 'deploy_upload_files_script'
  params:{
    storageAccountName: storageAccountModule.outputs.storageAccountOutput.name
    solutionLocation: solutionLocation
    containerName: storageAccountModule.outputs.storageAccountOutput.dataContainer
    identity: managedIdentityModule.outputs.managedIdentityOutput.id
    storageAccountKey: storageAccountModule.outputs.storageAccountOutput.key
    //azureOpenAIApiKey: 'test' //azOpenAI.outputs.openAIOutput.openAPIKey
    //azureOpenAIEndpoint: 'test' //azOpenAI.outputs.openAIOutput.openAPIEndpoint
    //azureSearchAdminKey: 'test' //azSearchService.outputs.searchServiceOutput.searchServiceAdminKey
    //azureSearchServiceEndpoint: 'test' //azSearchService.outputs.searchServiceOutput.searchServiceEndpoint
    baseUrl:baseUrl
  }
  //dependsOn:[storageAccountModule,azSearchService,azOpenAI]
}



// module azureFunctions 'deploy_azure_function_script.bicep' = {
//   name : 'deploy_azure_function_script'
//   params:{
//     solutionName: solutionPrefix
//     solutionLocation: solutionLocation
//     resourceGroupName:resourceGroupName
//     azureOpenAIApiKey:azOpenAI.outputs.openAIOutput.openAPIKey
//     azureOpenAIApiVersion:'2024-02-15-preview'
//     azureOpenAIEndpoint:azOpenAI.outputs.openAIOutput.openAPIEndpoint
//     azureSearchAdminKey:azSearchService.outputs.searchServiceOutput.searchServiceAdminKey
//     azureSearchServiceEndpoint:azSearchService.outputs.searchServiceOutput.searchServiceEndpoint
//     azureSearchIndex:'transcripts_index'
//     sqlServerName:sqlDBModule.outputs.sqlDbOutput.sqlServerName
//     sqlDbName:sqlDBModule.outputs.sqlDbOutput.sqlDbName
//     sqlDbUser:sqlDBModule.outputs.sqlDbOutput.sqlDbUser
//     sqlDbPwd:sqlDBModule.outputs.sqlDbOutput.sqlDbPwd
//     identity:managedIdentityModule.outputs.managedIdentityOutput.id
//     baseUrl:baseUrl
//   }
//   dependsOn:[storageAccountModule]
// }



// // ========== Key Vault ========== //
// module keyvaultModule 'deploy_keyvault.bicep' = {
//   name: 'deploy_keyvault'
//   params: {
//     solutionName: solutionPrefix
//     solutionLocation: solutionLocation
//     objectId: managedIdentityModule.outputs.managedIdentityOutput.objectId
//     tenantId: subscription().tenantId
//     managedIdentityObjectId:managedIdentityModule.outputs.managedIdentityOutput.objectId
//     adlsAccountName:storageAccountModule.outputs.storageAccountOutput.storageAccountName
//     adlsAccountKey:storageAccountModule.outputs.storageAccountOutput.key
//     azureOpenAIApiKey:azOpenAI.outputs.openAIOutput.openAPIKey
//     azureOpenAIApiVersion:'2024-02-15-preview'
//     azureOpenAIEndpoint:azOpenAI.outputs.openAIOutput.openAPIEndpoint
//     azureSearchAdminKey:azSearchService.outputs.searchServiceOutput.searchServiceAdminKey
//     azureSearchServiceEndpoint:azSearchService.outputs.searchServiceOutput.searchServiceEndpoint
//     azureSearchServiceName:azSearchService.outputs.searchServiceOutput.searchServiceName
//     azureSearchIndex:'transcripts_index'
//     cogServiceEndpoint:azAIMultiServiceAccount.outputs.cogSearchOutput.cogServiceEndpoint
//     cogServiceName:azAIMultiServiceAccount.outputs.cogSearchOutput.cogServiceName
//     cogServiceKey:azAIMultiServiceAccount.outputs.cogSearchOutput.cogServiceKey
//     sqlServerName:sqlDBModule.outputs.sqlDbOutput.sqlServerName
//     sqlDbName:sqlDBModule.outputs.sqlDbOutput.sqlDbName
//     sqlDbUser:sqlDBModule.outputs.sqlDbOutput.sqlDbUser
//     sqlDbPwd:sqlDBModule.outputs.sqlDbOutput.sqlDbPwd
//     enableSoftDelete:false
//   }
//   scope: resourceGroup(resourceGroup().name)
//   dependsOn:[storageAccountModule,azOpenAI,azSearchService,sqlDBModule]
// }

// module createIndex 'deploy_index_scripts.bicep' = {
//   name : 'deploy_index_scripts'
//   params:{
//     solutionLocation: solutionLocation
//     identity:managedIdentityModule.outputs.managedIdentityOutput.id
//     baseUrl:baseUrl
//     keyVaultName:keyvaultModule.outputs.keyvaultOutput.name
//   }
//   dependsOn:[keyvaultModule]
// }

// module azureFunctions 'deploy_azure_function_script_new.bicep' = {
//   name : 'deploy_azure_function_script_new'
//   params:{
//     solutionName: solutionPrefix
//     solutionLocation: solutionLocation
//     resourceGroupName:resourceGroupName
//     sqlServerName:sqlDBModule.outputs.sqlDbOutput.sqlServerName
//     sqlDbName:sqlDBModule.outputs.sqlDbOutput.sqlDbName
//     sqlDbUser:sqlDBModule.outputs.sqlDbOutput.sqlDbUser
//     sqlDbPwd:sqlDBModule.outputs.sqlDbOutput.sqlDbPwd
//     baseUrl:baseUrl
//   }
// }

// module azureragFunctions 'deploy_azure_function_script_new_rag.bicep' = {
//   name : 'deploy_azure_function_script_new_rag'
//   params:{
//     solutionName: solutionPrefix
//     solutionLocation: solutionLocation
//     resourceGroupName:resourceGroupName
//     azureOpenAIApiKey:azOpenAI.outputs.openAIOutput.openAPIKey
//     azureOpenAIApiVersion:'2024-02-15-preview'
//     azureOpenAIEndpoint:azOpenAI.outputs.openAIOutput.openAPIEndpoint
//     azureSearchAdminKey:azSearchService.outputs.searchServiceOutput.searchServiceAdminKey
//     azureSearchServiceEndpoint:azSearchService.outputs.searchServiceOutput.searchServiceEndpoint
//     azureSearchIndex:'call_transcripts_index'
//     sqlServerName:sqlDBModule.outputs.sqlDbOutput.sqlServerName
//     sqlDbName:sqlDBModule.outputs.sqlDbOutput.sqlDbName
//     sqlDbUser:sqlDBModule.outputs.sqlDbOutput.sqlDbUser
//     sqlDbPwd:sqlDBModule.outputs.sqlDbOutput.sqlDbPwd
//     baseUrl:baseUrl
//   }
// }

// module azureFunctionURL 'deploy_azure_function_script_url.bicep' = {
//   name : 'deploy_azure_function_script_url'
//   params:{
//     solutionName: solutionPrefix
//     identity:managedIdentityModule.outputs.managedIdentityOutput.id
//   }
//   dependsOn:[azureFunctions]
// }


// // module createaihub 'deploy_aihub_scripts.bicep' = {
// //   name : 'deploy_aihub_scripts'
// //   params:{
// //     solutionLocation: solutionLocation
// //     identity:managedIdentityModule.outputs.managedIdentityOutput.id
// //     baseUrl:baseUrl
// //     keyVaultName:keyvaultModule.outputs.keyvaultOutput.name
// //     solutionName: solutionPrefix
// //     resourceGroupName:resourceGroupName
// //     subscriptionId:subscriptionId
// //   }
// //   dependsOn:[keyvaultModule]
// // }

// module appserviceModule 'deploy_app_service.bicep' = {
//   name: 'deploy_app_service'
//   params: {
//     identity:managedIdentityModule.outputs.managedIdentityOutput.id
//     solutionName: solutionPrefix
//     solutionLocation: solutionLocation
//     AzureOpenAIEndpoint:azOpenAI.outputs.openAIOutput.openAPIEndpoint
//     AzureOpenAIModel:'gpt-4o-mini'
//     AzureOpenAIKey:azOpenAI.outputs.openAIOutput.openAPIKey
//     azureOpenAIApiVersion:'2024-02-15-preview'
//     USE_GRAPHRAG:'False'
//     GRAPHRAG_URL:'TBD'
//     RAG_URL:'TBD'
//   }
//   scope: resourceGroup(resourceGroup().name)
//   dependsOn:[azOpenAI,azAIMultiServiceAccount,azSearchService,sqlDBModule,azureFunctionURL]
// }

// module appserviceModule 'deploy_app_service.bicep' = {
//   name: 'deploy_app_service'
//   params: {
//     identity:managedIdentityModule.outputs.managedIdentityOutput.id
//     solutionName: solutionPrefix
//     solutionLocation: solutionLocation
//     AzureSearchService:azSearchService.outputs.searchServiceOutput.searchServiceName
//     AzureSearchIndex:'transcripts_index'
//     AzureSearchKey:azSearchService.outputs.searchServiceOutput.searchServiceAdminKey
//     AzureSearchUseSemanticSearch:'True'
//     AzureSearchSemanticSearchConfig:'my-semantic-config'
//     AzureSearchIndexIsPrechunked:'False'
//     AzureSearchTopK:'5'
//     AzureSearchContentColumns:'content'
//     AzureSearchFilenameColumn:'chunk_id'
//     AzureSearchTitleColumn:'client_id'
//     AzureSearchUrlColumn:'sourceurl'
//     AzureOpenAIResource:azOpenAI.outputs.openAIOutput.openAPIEndpoint
//     AzureOpenAIEndpoint:azOpenAI.outputs.openAIOutput.openAPIEndpoint
//     AzureOpenAIModel:'gpt-4'
//     AzureOpenAIKey:azOpenAI.outputs.openAIOutput.openAPIKey
//     AzureOpenAIModelName:'gpt-4'
//     AzureOpenAITemperature:'0'
//     AzureOpenAITopP:'1'
//     AzureOpenAIMaxTokens:'1000'
//     AzureOpenAIStopSequence:''
//     AzureOpenAISystemMessage:'''You are a helpful Wealth Advisor assistant''' 
//     AzureOpenAIApiVersion:'2024-02-15-preview'
//     AzureOpenAIStream:'True'
//     AzureSearchQueryType:'simple'
//     AzureSearchVectorFields:'contentVector'
//     AzureSearchPermittedGroupsField:''
//     AzureSearchStrictness:'3'
//     AzureOpenAIEmbeddingName:'text-embedding-ada-002'
//     AzureOpenAIEmbeddingkey:azOpenAI.outputs.openAIOutput.openAPIKey
//     AzureOpenAIEmbeddingEndpoint:azOpenAI.outputs.openAIOutput.openAPIEndpoint
//     USE_AZUREFUNCTION:'True'
//     STREAMING_AZUREFUNCTION_ENDPOINT: azureFunctionURL.outputs.functionAppUrl
//     SQLDB_SERVER:sqlDBModule.outputs.sqlDbOutput.sqlServerName
//     SQLDB_DATABASE:sqlDBModule.outputs.sqlDbOutput.sqlDbName
//     SQLDB_USERNAME:sqlDBModule.outputs.sqlDbOutput.sqlDbUser
//     SQLDB_PASSWORD:sqlDBModule.outputs.sqlDbOutput.sqlDbPwd
//     AZURE_COSMOSDB_ACCOUNT: cosmosDBModule.outputs.cosmosOutput.cosmosAccountName
//     AZURE_COSMOSDB_ACCOUNT_KEY: cosmosDBModule.outputs.cosmosOutput.cosmosAccountKey
//     AZURE_COSMOSDB_CONVERSATIONS_CONTAINER: cosmosDBModule.outputs.cosmosOutput.cosmosContainerName
//     AZURE_COSMOSDB_DATABASE: cosmosDBModule.outputs.cosmosOutput.cosmosDatabaseName
//     AZURE_COSMOSDB_ENABLE_FEEDBACK: 'True'
//     VITE_POWERBI_EMBED_URL: 'TBD'
//   }
//   scope: resourceGroup(resourceGroup().name)
//   dependsOn:[azOpenAI,azAIMultiServiceAccount,azSearchService,sqlDBModule,azureFunctionURL,cosmosDBModule]
// }
