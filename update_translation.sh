#!/bin/bash

translations_file="$1"

# If translations file exists declare translations associative array
if [ -f "$translations_file" ]; then
    declare -A translations
    source -- "$translations_file"

    echo "Updating translations file: $translations_file"
    read -p "Translation to update: " hexkey
    echo "Updating translation of: " $(xxd -r -p <<< "$hexkey")
    echo "Old translation: ${translations[$hexkey]}"
    read -p "New translation: " new_translation
    translations["$hexkey"]="$new_translation"
    declare -p translations > "$translations_file"
    echo "Updated translation: ${translations[$hexkey]}"
    
else
    echo "No translations file to update"
fi
