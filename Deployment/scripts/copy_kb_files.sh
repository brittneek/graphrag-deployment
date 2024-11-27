#!/bin/bash
echo "installing required libraries"
echo "Current working directory: $(pwd)"
python --version
python -m venv venv
source venv/bin/activate
# pip install graphrag==0.3.6
# pip install -r https://raw.githubusercontent.com/brittneek/graphrag-deployment/main/Deployment/scripts/graphrag-requirements.txt