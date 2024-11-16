#!/bin/bash

# Docker Cleanup Script
# This script helps maintain Docker system by cleaning up unused resources

echo "=== Docker Cleanup Script ==="
date

# Function to check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        echo "Error: Docker is not running or not installed"
        exit 1
    fi
}

# Function to display sizes
display_sizes() {
    echo -e "\nCurrent Docker disk usage:"
    docker system df
}

# Check Docker status
check_docker

# Display initial disk usage
display_sizes

echo -e "\nStarting cleanup process..."

# Stop all running containers
echo -e "\n1. Stopping all running containers..."
docker stop $(docker ps -q) 2>/dev/null
if [ $? -eq 0 ]; then
    echo "All containers stopped"
else
    echo "No running containers found"
fi

# Remove stopped containers
echo -e "\n2. Removing stopped containers..."
docker container prune -f
echo "Stopped containers removed"

# Remove unused images
echo -e "\n3. Removing unused images..."
docker image prune -a -f
echo "Unused images removed"

# Remove unused volumes
echo -e "\n4. Removing unused volumes..."
docker volume prune -f
echo "Unused volumes removed"

# Remove unused networks
echo -e "\n5. Removing unused networks..."
docker network prune -f
echo "Unused networks removed"

# Remove build cache
echo -e "\n6. Removing build cache..."
docker builder prune -f
echo "Build cache removed"

# Display final disk usage
echo -e "\nCleanup completed!"
display_sizes

echo -e "\nDocker system cleanup completed successfully!"
