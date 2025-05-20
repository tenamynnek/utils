#!/bin/bash

# Directory where Snap stores aws-cli revisions
SNAP_DIR="/snap/aws-cli"

# Check if the Snap aws-cli directory exists
if [ ! -d "$SNAP_DIR" ]; then
    echo "Error: $SNAP_DIR does not exist. No Snap-installed aws-cli found."
    exit 1
fi

# Check if aws-cli is installed via Snap
if ! snap list aws-cli > /dev/null 2>&1; then
    echo "Error: aws-cli is not installed via Snap."
    exit 1
fi

# Get the current active revision
CURRENT_REV=$(snap list aws-cli | grep -v "disabled" | grep "aws-cli" | awk '{print $3}')
if [ -z "$CURRENT_REV" ]; then
    echo "Error: Could not determine the current active revision of aws-cli."
    exit 1
fi

# Verify the current revision directory exists
CURRENT_DIR="$SNAP_DIR/$CURRENT_REV"
if [ ! -d "$CURRENT_DIR" ]; then
    echo "Error: Current revision directory $CURRENT_DIR does not exist."
    exit 1
fi

echo "Current AWS CLI Snap revision: $CURRENT_REV"

# List all installed revisions, including disabled ones
echo "Searching for old revisions to delete..."
snap list aws-cli --all | grep "disabled" | awk '{print $3}' | while read -r OLD_REV; do
    if [ -n "$OLD_REV" ] && [ "$OLD_REV" != "$CURRENT_REV" ]; then
        echo "Deleting old revision: $OLD_REV"
        sudo snap remove aws-cli --revision="$OLD_REV"
        if [ $? -eq 0 ]; then
            echo "Successfully deleted revision $OLD_REV"
        else
            echo "Failed to delete revision $OLD_REV. Check permissions or Snap status."
        fi
    fi
done

echo "Cleanup complete. Only revision $CURRENT_REV remains."
