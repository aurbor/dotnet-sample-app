#!/bin/bash

# Script to generate base Kubernetes manifests from Helm chart
# This should be run whenever the Helm chart templates or values change

set -e

echo "Generating base manifests from Helm chart..."

# Generate the manifests using Helm template
helm template weather-api . > base/all.yaml

echo "Base manifests generated successfully in base/all.yaml"
echo "You can now use kustomize to build environment-specific overlays"
