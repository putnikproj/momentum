#!/usr/bin/env bash

set -euo pipefail

RAILWAY_BINARY="/tmp/railway"
RAILWAY_VERSION="1.8.4"
RAILWAY_ENVIRONMENT="${RAILWAY_ENVIRONMENT:-production}"

# Cleanup function to run on exit
cleanup() {
    echo "Cleaning up..."
}

# Set trap to ensure cleanup runs even if script fails
trap cleanup EXIT

# Install the Railway CLI
echo "Installing Railway CLI version $RAILWAY_VERSION..."
mkdir -p /tmp
sh -c "$(curl -fsSL https://raw.githubusercontent.com/railwayapp/cli/master/install.sh)" -- -d "$RAILWAY_BINARY"

# The install script creates a 'railway' binary in the specified directory
if [ -f "$RAILWAY_BINARY/railway" ]; then
    RAILWAY_BINARY="$RAILWAY_BINARY/railway"
elif [ -f "$RAILWAY_BINARY" ]; then
    # Already correct path
    :
else
    echo "❌ Error: Railway CLI installation failed"
    exit 1
fi

chmod +x "$RAILWAY_BINARY"
$RAILWAY_BINARY version

# Construct the token environment variable name
# Format: RAILWAY_TOKEN__<PROJECT>_<ENVIRONMENT>
token_env_var="RAILWAY_TOKEN__MOMENTUM_$(echo "$RAILWAY_ENVIRONMENT" | awk '{print toupper($0)}')"

echo "Looking for Railway token: $token_env_var"

# Read the Railway token from environment variables
railway_token="${!token_env_var:-}"

if [ -z "$railway_token" ]; then
    echo "❌ Error: Railway token not found (expected env var: $token_env_var)"
    echo "Please set the $token_env_var secret in your GitHub repository"
    exit 1
fi

echo "✓ Railway token found"

# Get all app projects from Nx
echo "Discovering all app projects..."
all_projects=$(pnpm nx show projects --type=app | grep -v 'e2e')

for project in $all_projects
do
    echo "================================================"
    echo "Processing: '$project'..."
    
    # Change to project directory
    project_path="apps/$project"
    
    if [ ! -d "$project_path" ]; then
        echo "⚠️  Warning: Project directory not found: $project_path"
        echo "Skipping deployment for $project"
        continue
    fi
    
    echo "✓ Deploying $project to Railway environment: $RAILWAY_ENVIRONMENT"
    
    # Trigger the deploy using the single Railway token
    cd "$project_path"
    RAILWAY_TOKEN="$railway_token" $RAILWAY_BINARY up --detach
    cd - > /dev/null
    
    echo "✓ Deployment triggered for $project"
done

echo "================================================"
echo "✓ All deployments completed"
