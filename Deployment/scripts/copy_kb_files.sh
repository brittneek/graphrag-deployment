#!/bin/bash
echo "installing required libraries"
echo "Current working directory: $(pwd)"
python --version
# Create the virtual environment in a writable directory
python3 -m venv /tmp/venv

# Activate the virtual environment
source /tmp/venv/bin/activate
# pip install graphrag==0.3.6
pip install -r https://raw.githubusercontent.com/brittneek/graphrag-deployment/main/Deployment/scripts/graphrag-requirements.txt
# python -m graphrag.index --root ./ --verbose
cd graphrag
python pipeline_index.py