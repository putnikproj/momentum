#!/usr/bin/env bash

set -euo pipefail

RAILWAY_ENVIRONMENT="${RAILWAY_ENVIRONMENT:-production}"

# Ensure Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "Installing Railway CLI..."
    bash <(curl -fsSL cli.new)
fi

echo "Railway CLI version:"
railway version

# Validate RAILWAY_TOKEN is set
if [ -z "${RAILWAY_TOKEN:-}" ]; then
    echo "❌ Error: RAILWAY_TOKEN environment variable is not set"
    echo "Please set the RAILWAY_TOKEN secret in your GitHub repository"
    exit 1
fi

echo "✓ Railway token found"

# Get all app projects from Nx (excluding e2e projects)
echo "Discovering all app projects..."
all_projects=$(pnpm nx show projects --type=app | grep -v 'e2e')

for project in $all_projects
do
    echo "================================================"
    echo "Deploying: '$project' to environment: $RAILWAY_ENVIRONMENT"

    # Deploy pre-built artifacts from the Nx build output directory
    build_path="dist/apps/$project"

    if [ ! -d "$build_path" ]; then
        echo "⚠️  Warning: Build output not found: $build_path"
        echo "Skipping deployment for $project"
        continue
    fi

    # Deploy the built artifacts
    cd "$build_path"
    railway up --detach --environment "$RAILWAY_ENVIRONMENT"
    cd - > /dev/null

    echo "✓ Deployment triggered for $project"
done

echo "================================================"
echo "✓ All deployments completed"
