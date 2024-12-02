# Use Python 3.12 as the base image
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Install system dependencies, including Rust and Cargo
RUN apt-get update && apt-get install -y \
    build-essential \
    cargo \
    && apt-get clean

# Copy files to the container
COPY copy_kb_files.sh /app/copy_kb_files.sh
COPY graphrag-requirements.txt /app/graphrag-requirements.txt
# RUN pip install -r /app/graphrag-requirements.txt
COPY pipeline_index.py /app/pipeline_index.py
COPY settings.yaml /app/settings.yaml

# Make the shell script executable
RUN chmod +x /app/copy_kb_files.sh

# Run the setup script during build
RUN /app/copy_kb_files.sh


# Default command to run your Python script
CMD ["python", "pipeline_index.py"]