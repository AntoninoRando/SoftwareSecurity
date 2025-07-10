#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change to the script directory
cd "$SCRIPT_DIR"

# Check if Dockerfile exists
if [ ! -f "Dockerfile" ]; then
    echo "Error: Dockerfile not found in $SCRIPT_DIR"
    exit 1
fi

# Build the Docker image
echo "Building Docker image..."
docker build -t imagemagick-fuzzer-image .

# Check if build was successful
if [ $? -ne 0 ]; then
    echo "Error: Docker build failed"
    exit 1
fi

# Remove existing container if it exists
echo "Removing existing container if it exists..."
docker rm -f imagemagick-fuzzer 2>/dev/null

# Run the container interactively
echo "Starting interactive container..."
docker run -it --name imagemagick-fuzzer imagemagick-fuzzer-image

echo "Container session ended."