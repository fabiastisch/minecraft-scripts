#!/bin/bash

source .secret

Filename=new-mc-server_tmp.zip

echo "Project id: $CURSEFORGE_PROJEKT_ID"
echo "API_KEY: $CURSEFORGE_API_KEY"

API_Mod_Details_URL="https://api.curseforge.com/v1/mods/$CURSEFORGE_PROJEKT_ID"

echo "$API_Mod_Details_URL"

response=$(curl -sL \
  --url "$API_Mod_Details_URL" \
  -H "Accept: application/json" \
  -H "x-api-key: $CURSEFORGE_API_KEY")

ServerFileId=$(echo "$response" | jq -r '.data.latestFiles[0].serverPackFileId')

if [ -z "$ServerFileId" ]; then
    echo "Error while extracting The ServerFileId from response"
    exit 1
fi


echo "Request ServerFileID: $ServerFileId"

API_Mod_ServerFiles_Download_URL="https://api.curseforge.com/v1/mods/$CURSEFORGE_PROJEKT_ID/files/$ServerFileId/download-url"

response=$(curl -sL \
  --url "$API_Mod_ServerFiles_Download_URL" \
  -H "Accept: application/json" \
  -H "x-api-key: $CURSEFORGE_API_KEY")

ServerFile_Download_Url=$(echo "$response" | jq -r '.data' )

echo "Download url: $ServerFile_Download_Url"



curl -L -o "$Filename" "$ServerFile_Download_Url"

if [ $? -ne 0 ]; then
  echo "Error while downloading Server file"
  exit 1
fi

# Unzip to parent dir
echo "Unzip $Filename"
unzip -d "../" "$Filename"

if [ $? -ne 0 ]; then
  echo "Error while unzipping the file."
  exit 1
fi

# remove tmp downloaded zip file
rm "$Filename"

echo "Finished Install NewestVersion."
exit 0