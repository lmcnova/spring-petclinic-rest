#!/bin/bash
# Setup and Run script for Spring PetClinic REST Application
# Usage: ./setup-and-run.sh

set -e

echo "============================================"
echo "  Spring PetClinic REST - Setup & Run"
echo "============================================"

# Check Java is installed
echo ""
echo "[1/3] Checking prerequisites..."
if ! command -v java &> /dev/null; then
    echo "ERROR: Java is not installed or not in PATH."
    echo "This project requires Java 17+."
    echo "Download from: https://adoptium.net/"
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | cut -d'.' -f1)
echo "  Java version: $(java -version 2>&1 | head -1)"

if [ "$JAVA_VERSION" -lt 17 ] 2>/dev/null; then
    echo "WARNING: Java 17+ is recommended. You have Java $JAVA_VERSION."
fi

# Build the project
echo ""
echo "[2/3] Building the application (skipping tests for faster startup)..."
./mvnw clean install -DskipTests

# Run the application
echo ""
echo "[3/3] Starting Spring PetClinic REST application..."
echo ""
echo "  Application URL : http://localhost:9966/petclinic/"
echo "  Swagger UI      : http://localhost:9966/petclinic/swagger-ui.html"
echo "  Health Check    : http://localhost:9966/petclinic/actuator/health"
echo ""
echo "  Press Ctrl+C to stop the application."
echo "============================================"
echo ""

./mvnw spring-boot:run
