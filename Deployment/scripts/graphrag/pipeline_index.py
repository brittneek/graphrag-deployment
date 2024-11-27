import asyncio
import inspect
import os
import sys
import time

import yaml
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from graphrag.config import create_graphrag_config
from graphrag.index.api import build_index
from graphrag.index.cli import _register_signal_handlers, _logger
from graphrag.index.emit import TableEmitterType
from graphrag.index.progress import ReporterType
from graphrag.index.progress.load_progress_reporter import load_progress_reporter



def building_index():
    # Assuming these arguments are similar to what argparse would receive
    root_dir = "./"
    config_path = "./settings.yaml"

    this_directory = os.path.dirname(
        os.path.abspath(inspect.getfile((inspect.currentframe())))
    )

    # get settings
    settings = yaml.safe_load(open(f"{this_directory}/settings.yaml"))

    updated_settings = set_graphrag_config_values(settings)

    # get parameters
    config = create_graphrag_config(updated_settings, ".")

    resume = ''
    update_index_id = False
    reporter = ReporterType.RICH
    emit = [TableEmitterType(TableEmitterType.Parquet.value)]

    """Run the pipeline with the given config."""
    progress_reporter = load_progress_reporter(reporter)
    info, error, success = _logger(progress_reporter)
    run_id = resume or update_index_id or time.strftime("%Y%m%d-%H%M%S")


    outputs = asyncio.run(
        build_index(
            config=config,
            run_id=run_id,
            is_resume_run=False,
            is_update_run=False,
            memory_profile=False,
            progress_reporter=progress_reporter,
            emit=emit,
        )
    )
    encountered_errors = any(
        output.errors and len(output.errors) > 0 for output in outputs
    )

    progress_reporter.stop()
    if encountered_errors:
        error(
            "Errors occurred during the pipeline run, see logs for more details.", True
        )
    else:
        success("All workflows completed successfully.", True)

    sys.exit(1 if encountered_errors else 0)


def set_graphrag_config_values(settings):

    key_vault_name = 'knowledge-mining-kv'

    settings['llm']['api_key'] = get_secrets_from_kv(key_vault_name,'AZURE-OPENAI-API-KEY')
    settings['llm']['model'] = 'gpt-4o-mini' # just update the model name during deployment
    settings['llm']['api_base'] = get_secrets_from_kv(key_vault_name, 'AZURE-OPENAI-ENDPOINT')
    settings['llm']['api_version'] = get_secrets_from_kv(key_vault_name, 'AZURE-OPENAI-API-VERSION')
    settings['llm']['deployment_name'] = 'gpt-4o-mini'

    # embeddings
    settings['embeddings']['vector_store']['url'] = get_secrets_from_kv(key_vault_name, 'GRAPHRAG-AZURE-SEARCH-ENDPOINT')
    settings['embeddings']['vector_store']['api_key'] = get_secrets_from_kv(key_vault_name, 'GRAPHRAG-AZURE-SEARCH-KEY')
    settings['embeddings']['llm']['api_key'] = get_secrets_from_kv(key_vault_name,'AZURE-OPENAI-API-KEY')
    settings['embeddings']['llm']['api_base'] = get_secrets_from_kv(key_vault_name, 'AZURE-OPENAI-ENDPOINT')
    settings['embeddings']['llm']['api_version'] = '2024-05-01-preview' # set during deployment
    settings['embeddings']['llm']['deployment_name'] = 'text-embedding-ada-002' # set during deployment

    # container name
    settings['input']['container_name'] = get_secrets_from_kv(key_vault_name, 'GRAPHRAG-AZURE-STORAGE-CONTAINER-NAME')
    settings['cache']['container_name'] = get_secrets_from_kv(key_vault_name, 'GRAPHRAG-AZURE-STORAGE-CONTAINER-NAME')
    settings['storage']['container_name'] = get_secrets_from_kv(key_vault_name, 'GRAPHRAG-AZURE-STORAGE-CONTAINER-NAME')
    settings['reporting']['container_name'] = get_secrets_from_kv(key_vault_name, 'GRAPHRAG-AZURE-STORAGE-CONTAINER-NAME')

    storage_account_name = get_secrets_from_kv(key_vault_name,'ADLS-ACCOUNT-NAME')
    storage_account_blob_url = f"https://{storage_account_name}.blob.core.windows.net/"

    # storage settings
    settings['input']['storage_account_blob_url'] = storage_account_blob_url
    settings['cache']['storage_account_blob_url'] = storage_account_blob_url
    settings['storage']['storage_account_blob_url'] = storage_account_blob_url
    settings['reporting']['storage_account_blob_url'] = storage_account_blob_url

    return settings


def get_secrets_from_kv(kv_name, secret_name):
    # Set the name of the Azure Key Vault
    key_vault_name = kv_name
    credential = DefaultAzureCredential()

    # Create a secret client object using the credential and Key Vault name
    secret_client = SecretClient(vault_url=f"https://{key_vault_name}.vault.azure.net/", credential=credential)

    # Retrieve the secret value
    return secret_client.get_secret(secret_name).value

building_index()