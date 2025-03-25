#!/bin/bash

history_file="$HOME/.last_translation"
time_regex='^.*[0-9]{2}[-:][0-9]{2}[-:][0-9]{2}.*$'
if [ -f "$history_file" ]; then
    last_translation=$(cat "$history_file")
fi

if [ -f "$HOME/.local/bin/.deepl_apikey" ]; then
    API_KEY=$(cat "$HOME/.local/bin/.deepl_apikey")

else
    echo "No APIKEY for DeepL API found. Create a file .deepl_apikey next to this script"
fi

clear
translate_text="$(wl-paste)"

if [ ! -z "$translate_text" ] && [ "$translate_text" != "$last_translation" ] && ! [[ "$translate_text" =~ $time_regex ]]; then
    echo $translate_text > "$history_file"
    printf $translate_text "\n"
    printf '\n
     -
    \n'
    curl --silent -X POST https://api-free.deepl.com/v2/translate   --header "Content-Type: application/json"   --header "Authorization: DeepL-Auth-Key $API_KEY"   --data '
      {
	      "text": ["'$translate_text'"],
	      "source_lang": "JA",
	      "target_lang": "EN"
      }' | jq -r .translations[0].text
fi
