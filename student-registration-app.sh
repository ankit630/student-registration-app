#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Docker if not already installed
if ! command_exists docker; then
    echo "Docker not found. Installing Docker..."
    curl -fsSL get.docker.com | sh
    sudo systemctl enable docker
    sudo systemctl start docker
else
    echo "Docker is already installed."
fi

# Ensure Docker service is running
if ! systemctl is-active --quiet docker; then
    echo "Starting Docker service..."
    sudo systemctl start docker
fi

# Wait for Docker to be ready
echo "Waiting for Docker to be ready..."
timeout=30
while ! docker info >/dev/null 2>&1; do
    if [ $timeout -le 0 ]; then
        echo "Timed out waiting for Docker to be ready."
        exit 1
    fi
    timeout=$((timeout - 1))
    sleep 1
done

# Build the Docker image
echo "Building Docker image..."
docker build -t student-registration-app --build-arg BUILD_VERSION=1.0.0 .

# Create a directory for logs if it doesn't exist
mkdir -p ./app_logs

# Run the Docker container
echo "Running Docker container..."
docker run -d -p 3000:3000 -v "$(pwd)/app_logs:/app/logs" --name devops-classroom student-registration-app

echo "Application is now running. You can access it at http://localhost:3000"
echo "Logs are being saved to $(pwd)/app_logs"
