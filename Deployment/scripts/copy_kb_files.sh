#!/bin/bash
# echo "Installing Python 3.10 and pip"
# apt-get update && apt-get install -y software-properties-common
# add-apt-repository ppa:deadsnakes/ppa -y
# apt-get update && apt-get install -y python3.10 python3.10-venv python3.10-distutils

# # Set Python 3.10 as the default
# ln -sf /usr/bin/python3.10 /usr/bin/python
# ln -sf /usr/bin/python3.10 /usr/bin/python3

pip install --upgrade pip

# # Verify Python version
echo "Python version:"
python --version

# # Install pip for Python 3.10
# curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10

echo "installing required libraries"
echo "Current working directory: $(pwd)"
python --version
# Create the virtual environment in a writable directory
python3 -m venv /tmp/venv

# Activate the virtual environment
source /tmp/venv/bin/activate

echo "install lancedb"
pip install lancedb

pip install --upgrade pip
# pip install graphrag==0.3.6
# pip install -r https://raw.githubusercontent.com/brittneek/graphrag-deployment/main/Deployment/scripts/graphrag-requirements.txt
# python -m graphrag.index --root ./ --verbose
# echo "open graphrag folder"
# cd graphrag
# echo "run pipeline_index.py"
# python pipeline_index.py