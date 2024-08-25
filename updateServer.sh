#!/bin/bash

# Read Secrets
source ./.secret

# Set the paths for the source and destination modpacks
Version_New=$1
FolderName="Server-Files-"
# Get the newes matching Server-Files Folder (e.g. Server-Files 0.38)
Path_Version_Old="~/$(ls -d ~/${FolderName}* | sort -V | tail -n 1 | xargs basename)"
Path_Version_New="~/${FolderName}${Version_New}"

# Check if the source world folder exists
if [ ! -d "$Path_Version_Old/world" ]; then
    echo "Error: World folder not found in the source modpack."
    exit 1
fi

# Check if the destination modpack folder exists
if [ ! -d "$Path_Version_New" ]; then
    echo "Error: Destination modpack folder not found."
    exit 1
fi

# Check if the world directory already exists
if [ -d "$Path_Version_New/world" ]; then
    echo "Error: Directory already exitsts in destination."
    exit 1
fi

# Copy the world folder
cp -R "$Path_Version_Old/world" "$Path_Version_New/"

# Check if the copy was successful
if [ $? -eq 0 ]; then
    echo "World folder successfully copied to the updated modpack."
else
    echo "Error: Failed to copy the world folder."
    exit 1
fi


copy_file_to_path() {
    local source="${Path_Version_Old}/${1}"
    local destination="$Path_Version_New"

    # Check if source exists
    if [ ! -e "$source" ]; then
        echo "Error: Source '$source' does not exist."
        return 1
    fi

    # Create destination directory if it doesn't exist
    mkdir -p "$destination"

    # Copy files
    cp -R "$source" "$destination"

    # Check if copy was successful
    if [ $? -eq 0 ]; then
        echo "Successfully copied '$source' to '$destination'."
        return 0
    else
        echo "Error: Failed to copy '$source' to '$destination'."
        return 1
    fi
}

copy_file_to_path "eula.txt"
copy_file_to_path "ops.json"
copy_file_to_path "run.sh"
copy_file_to_path "usercache.json"



send_discord_notification() {
  local message=$1
  
  # Construct payload
  local payload=$(cat <<EOF
{
  "content": "$message"
}
EOF
)

  # Send POST request to Discord Webhook
  curl -H "Content-Type: application/json" -X POST -d "$payload" $WEBHOOK_URL
}

send_discord_notification "Update to new Version: $Version_New"