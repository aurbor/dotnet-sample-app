# Weather API - Helm + Kustomize Hybrid Approach

This directory contains a hybrid Helm + Kustomize configuration for the Weather API application. This approach combines the power of Helm templating for the base configuration with Kustomize overlays for environment-specific customizations.

## Architecture

```
charts/weather-api/
├── Chart.yaml                    # Helm chart metadata
├── values.yaml                   # Helm chart default values
├── generate-base.sh              # Script to regenerate base manifests
├── templates/                    # Helm templates
│   ├── deployment.yaml
│   └── service.yaml
├── base/                         # Kustomize base (generated from Helm)
│   ├── kustomization.yaml
│   └── all.yaml                  # Generated from Helm templates
└── overlays/                     # Environment-specific Kustomize overlays
    ├── dev/
    │   ├── kustomization.yaml
    │   └── deployment-patch.yaml
    └── prod/
        ├── kustomization.yaml
        └── deployment-patch.yaml
```

## How It Works

1. **Helm Templates**: Define the base Kubernetes manifests using Helm templating
2. **Base Generation**: Run `helm template` to generate static YAML manifests
3. **Kustomize Overlays**: Use Kustomize to patch the base manifests for different environments

## Workflow

### When Helm Templates Change

1. Update Helm templates in `templates/` directory
2. Update default values in `values.yaml`
3. Regenerate base manifests:
   ```bash
   cd charts/weather-api
   ./generate-base.sh
   ```
4. Commit both template changes and generated `base/all.yaml`

### When Environment Configuration Changes

1. Update the relevant overlay files in `overlays/{env}/`
2. No need to regenerate base manifests

## Environments

### Development Environment (`overlays/dev/`)

- **Namespace**: `dev`
- **Replicas**: 1
- **Image Tag**: `dev`
- **Resources**: Lower limits (32Mi memory, 100m CPU)
- **Environment Variables**:
  - `ASPNETCORE_ENVIRONMENT=Development`
  - `LOG_LEVEL=Debug`
- **Name Prefix**: `dev-`

### Production Environment (`overlays/prod/`)

- **Namespace**: `production`
- **Replicas**: 3
- **Image Tag**: `v1.0.0`
- **Resources**: Higher limits (256Mi memory, 500m CPU)
- **Environment Variables**:
  - `ASPNETCORE_ENVIRONMENT=Production`
  - `LOG_LEVEL=Information`
- **Health Checks**: Enabled with liveness and readiness probes
- **Name Prefix**: `prod-`

## Usage

### Building Manifests

```bash
# Base configuration (Helm-generated)
kubectl kustomize charts/weather-api/base

# Dev environment
kubectl kustomize charts/weather-api/overlays/dev

# Production environment
kubectl kustomize charts/weather-api/overlays/prod
```

### Deploying with kubectl

```bash
# Deploy to dev environment
kubectl apply -k charts/weather-api/overlays/dev

# Deploy to production environment
kubectl apply -k charts/weather-api/overlays/prod
```

### Testing Helm Templates Directly

```bash
# Test Helm templates with default values
helm template weather-api charts/weather-api

# Test with custom values
helm template weather-api charts/weather-api --values custom-values.yaml
```

## ArgoCD Integration

ArgoCD application manifests are available in the `environments/` directory:

- `environments/dev/weather-api-hybrid-app.yaml` - Dev environment
- `environments/prod/weather-api-hybrid-app.yaml` - Prod environment

These applications point to the Kustomize overlays, which automatically include the Helm-generated base.

## Benefits of This Approach

1. **Helm Power**: Use Helm's templating for complex logic and reusable charts
2. **Kustomize Simplicity**: Use Kustomize for straightforward environment differences
3. **GitOps Friendly**: All generated manifests are committed to Git
4. **ArgoCD Native**: Works seamlessly with ArgoCD's Kustomize support
5. **Flexibility**: Easy to add new environments or modify existing ones
6. **Maintainability**: Clear separation between base templates and environment patches

## Best Practices

1. **Always regenerate base**: Run `./generate-base.sh` after Helm template changes
2. **Version control**: Commit both source templates and generated manifests
3. **Review generated changes**: Always review the diff in `base/all.yaml` before committing
4. **Test locally**: Use `kubectl kustomize` to test before pushing
5. **Environment isolation**: Keep environment-specific changes in overlays only

## Troubleshooting

### Base manifests out of sync
```bash
cd charts/weather-api
./generate-base.sh
```

### Kustomize build fails
Check that:
- `base/all.yaml` exists and is valid YAML
- Patch files match the structure in the base manifests
- All referenced ConfigMaps and resources exist

### Helm template fails
Verify:
- `Chart.yaml` has correct version
- `values.yaml` has valid YAML syntax
- Templates use correct Helm functions
