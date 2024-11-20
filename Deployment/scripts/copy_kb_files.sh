#!/bin/bash

# Variables
storageAccount="$1"
fileSystem="$2"
accountKey="$3"
baseUrl="$4"
azureOpenAIApiKey="$5"
azureOpenAIEndpoint="$6"
azureSearchAdminKey="$7"
azureSearchServiceEndpoint="$8"

zipFileName1="transcriptsdata.zip"
extractedFolder1="transcriptsdata"
zipUrl1=${baseUrl}"Deployment/data/transcriptsdata.zip"

zipFileName2="transcriptstxtdata.zip"
extractedFolder2="input"
zipUrl2=${baseUrl}"Deployment/data/transcriptstxtdata.zip"

zipFileName3="ragtest.zip"
extractedFolder3="ragtest"
zipUrl3=${baseUrl}"Deployment/data/ragtest.zip"

graphragfileSystem="graphrag"

# # Download the zip file
# curl --output "$zipFileName1" "$zipUrl1"
# curl --output "$zipFileName2" "$zipUrl2"
# curl --output "$zipFileName3" "$zipUrl3"

# # Extract the zip file
# unzip /mnt/azscripts/azscriptinput/"$zipFileName1" -d /mnt/azscripts/azscriptinput/"$extractedFolder1"
# unzip /mnt/azscripts/azscriptinput/"$zipFileName2" -d /mnt/azscripts/azscriptinput/"$extractedFolder2"
# unzip /mnt/azscripts/azscriptinput/"$zipFileName3" -d /mnt/azscripts/azscriptinput/"$extractedFolder3"

# echo "Script Started"

# sed -i "s/<STORAGE_ACCOUNT_TO_BE_REPLACED>/${storageAccount}/g" "/mnt/azscripts/azscriptinput/ragtest/settings.yaml"
# sed -i "s/<GRAPHRAG_API_KEY_TO_BE_REPLACED>/${azureOpenAIApiKey}/g" "/mnt/azscripts/azscriptinput/ragtest/settings.yaml"
# # sed -i "s/<AOAI_TO_BE_REPLACED>/${azureOpenAIEndpoint}/g" "/mnt/azscripts/azscriptinput/ragtest/settings.yaml"
# sed -i "s|<AOAI_TO_BE_REPLACED>|${azureOpenAIEndpoint}|g" "/mnt/azscripts/azscriptinput/ragtest/settings.yaml"
# # sed -i "s/<AI_SEARCH_TO_BE_REPLACED>/${azureSearchServiceEndpoint}/g" "/mnt/azscripts/azscriptinput/ragtest/settings.yaml"
# sed -i "s|<AI_SEARCH_TO_BE_REPLACED>|${azureSearchServiceEndpoint}|g" "/mnt/azscripts/azscriptinput/ragtest/settings.yaml"
# sed -i "s/<AI_SEARCH_KEY_TO_BE_REPLACED>/${azureSearchAdminKey}/g" "/mnt/azscripts/azscriptinput/ragtest/settings.yaml"

# az storage fs directory upload -f "$fileSystem" --account-name "$storageAccount" -s "$extractedFolder1" --account-key "$accountKey" --recursive
# az storage fs directory upload -f "$graphragfileSystem" --account-name "$storageAccount" -s "$extractedFolder2" --account-key "$accountKey" --recursive
# az storage fs directory upload -f "$graphragfileSystem" --account-name "$storageAccount" -s "$extractedFolder3" --account-key "$accountKey" --recursive

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
    $PYTHON_VERSION -m venv $VENV_DIR --copies
    echo "Virtual environment created successfully."
else
    echo "Virtual environment already exists. Skipping creation."
fi

# Activate the virtual environment
echo "Activating the virtual environment..."
source $VENV_DIR/bin/activate

if [ $? -ne 0 ]; then
    echo "Error: Unable to activate virtual environment."
    exit 1
fi
echo "Virtual environment activated."

# Install pip and dependencies
echo "Installing pip..."
curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10
echo "Installing dependencies from $REQUIREMENTS_FILE..."
pip install --upgrade pip
if [ -f "$REQUIREMENTS_FILE" ]; then
    pip install -r $REQUIREMENTS_FILE
fi

# Deactivate the virtual environment
deactivate
echo "Python 3.10 virtual environment setup complete."

# requirementFile="graphrag-requirements.txt"
# requirementFileUrl=${baseUrl}"Deployment/scripts/graphrag-requirements.txt"
# curl --output "$requirementFile" "$requirementFileUrl"
# pip install -r graphrag-requirements.txt
# # pip install graphrag==0.3.6

# # python -m graphrag.index --root /mnt/azscripts/azscriptinput/ragtest
# # python -m graphrag index --root ./ragtest
# python -m graphrag index --root /mnt/azscripts/azscriptinput/ragtest