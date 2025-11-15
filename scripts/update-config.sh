#!/bin/bash
# Helper script to show new options in .example files that aren't in your .local.yml files
# Usage: ./scripts/update-config.sh [file]
# Example: ./scripts/update-config.sh users

set -e

VARS_DIR="vars"

if [ -z "$1" ]; then
    echo "Usage: $0 [config-name]"
    echo "Example: $0 users"
    echo ""
    echo "Available configs:"
    ls -1 "$VARS_DIR"/*.example 2>/dev/null | sed "s|$VARS_DIR/||" | sed 's/.example$//' | sed 's/^/  - /'
    exit 1
fi

CONFIG_NAME="$1"
EXAMPLE_FILE="$VARS_DIR/${CONFIG_NAME}.local.yml.example"
LOCAL_FILE="$VARS_DIR/${CONFIG_NAME}.local.yml"

if [ ! -f "$EXAMPLE_FILE" ]; then
    echo "Error: Example file not found: $EXAMPLE_FILE"
    exit 1
fi

if [ ! -f "$LOCAL_FILE" ]; then
    echo "Error: Local config file not found: $LOCAL_FILE"
    echo "Create it first: cp $EXAMPLE_FILE $LOCAL_FILE"
    exit 1
fi

echo "=========================================="
echo "Comparing $CONFIG_NAME configuration"
echo "=========================================="
echo ""
echo "New/commented options in example file that might not be in your local file:"
echo ""

# Extract commented options from example file (lines starting with # and containing :)
# Exclude pure comments (lines that are just comments without config)
grep -E '^#\s+[a-z_]+:' "$EXAMPLE_FILE" | sed 's/^#/  /' | head -20

echo ""
echo "To update your config:"
echo "1. Review the options above"
echo "2. Edit: nano $LOCAL_FILE"
echo "3. Uncomment and add any new options you want from: $EXAMPLE_FILE"
echo ""
echo "Your existing configuration will NOT be overwritten."

