#!/bin/bash

# Read Secrets
source ./.secret

output=$(./installNewestVersion.sh)

exit_code=$?
# Display script echos
echo "$output"

if [ $exit_code -ne 0 ]; then
        echo "installNewestVersion failed with exit code $exit_code"
        exit 1
fi


# Set the paths for the source and destination modpacks
FolderName="Server-Files-"
# Get the newes matching Server-Files Folder (e.g. Server-Files 0.38)
Path_Version_Old="$(ls -d ~/${FolderName}* | sort -V | tail -n 2 | head -n 1)"


# Check if the source world folder exists
if [ ! -d "${Path_Version_Old}/world" ]; then
    echo "Error: World folder not found in the source modpack. Check Path: $Path_Version_Old"
    exit 1
fi

#read -p "Input new Version (e.g. 0.40): " Version_New
Path_Version_New="$(ls -d ~/${FolderName}* | sort -V | tail -n 1 | head -n 1)"
# Check if the destination modpack folder exists
if [ ! -d "$Path_Version_New" ]; then
    echo "Error: Destination modpack folder not found. (${Path_Version_New}"
    exit 1
fi

# Check if the world directory already exists
if [ -d "$Path_Version_New/world" ]; then
    echo "Error: Directory already exitsts in destination. (${Path_Version_New}/world"
    exit 1
fi

# Copy the world folder
sudo cp -R "$Path_Version_Old/world" "$Path_Version_New/"

# Check if the copy was successful
if [ $? -eq 0 ]; then
    echo "World folder successfully copied to the updated modpack."
else
    echo "Error: Failed to copy the world folder."
    exit 1
fi


copy_file_to_path_internal() {
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
    sudo cp -R "$source" "$destination"

    # Check if copy was successful
    if [ $? -eq 0 ]; then
        echo "Successfully copied '$source' to '$destination'."
        return 0
    else
        echo "Error: Failed to copy '$source' to '$destination'."
        return 1
    fi
}
copy_file_to_path(){
    copy_file_to_path_internal $1
    if [ $? -ne 0 ]; then
        echo "copy_file_to_path_internal failed for argument: ${1}"
        exit 1
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

Discord_Notif=$(echo "$Path_Version_New" | tr -cd '0-9.')

send_discord_notification "Update to new Version: $Discord_Notif"