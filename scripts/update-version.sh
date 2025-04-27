#!/bin/bash

ENV_FILE=".env"
VERSION_KEY="REACT_APP_VERSION"

# Check if the .env file exists
if [ ! -f "$ENV_FILE" ]; then
  echo "$ENV_FILE does not exist. Creating it..."
  touch "$ENV_FILE"
fi

# Read the current version from the .env file
CURRENT_VERSION=$(grep "^$VERSION_KEY=" "$ENV_FILE" | cut -d '=' -f2)

# Increment the version or initialize it to 1 if not found
if [[ -n "$CURRENT_VERSION" && "$CURRENT_VERSION" =~ ^[0-9]+$ ]]; then
  NEW_VERSION=$((CURRENT_VERSION + 1))
else
  NEW_VERSION=1
fi

# Update or add the REACT_APP_VERSION in the .env file
if grep -q "^$VERSION_KEY=" "$ENV_FILE"; then
  sed -i '' "s/^$VERSION_KEY=.*/$VERSION_KEY=$NEW_VERSION/" "$ENV_FILE"
else
  echo "$VERSION_KEY=$NEW_VERSION" >> "$ENV_FILE"
fi

echo "Updated $VERSION_KEY to $NEW_VERSION in $ENV_FILE"