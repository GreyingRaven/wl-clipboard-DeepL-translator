#!/bin/bash

# Create config folder
mkdir -p "$HOME/.config/wl-translator"
# Set file varibles
history_file="$HOME/.config/wl-translator/.last_translation"
apikey_file="$HOME/.config/wl-translator/.deepl_apikey"
# Set time exclusion regex
time_regex='^.*[0-9]{2}[-:][0-9]{2}[-:][0-9]{2}.*$'
# Check if there is something saved as a previous text to translate
if [ -f "$history_file" ]; then
    last_translation=$(cat "$history_file")
fi
# Check if there is an API key, only continue if there is
if [ -f "$apikey_file" ]; then
    API_KEY=$(cat "$apikey_file")
    # Asign text to translate from clipboard
    translate_text="$(wl-paste)"

    # Check if the text to translate is:
    ## Not empty
    ## Not equal to last translation
    ## Doesn't contain time
    if [ ! -z "$translate_text" ] && [ "$translate_text" != "$last_translation" ] && ! [[ "$translate_text" =~ $time_regex ]]; then
	# Clear terminal to remove previous translation
	clear
	# Update history with latest translation
	echo $translate_text > "$history_file"
	# TODO persist translation for later recovery
	# Print response with following format
	## Original text
	## -
	## Translation
	printf $translate_text
	printf '\n
     -
    \n'
	# Calls deepl free api and prints the translated text
	curl --silent -X POST https://api-free.deepl.com/v2/translate   --header "Content-Type: application/json"   --header "Authorization: DeepL-Auth-Key $API_KEY"   --data '
      {
	      "text": ["'$translate_text'"],
	      "source_lang": "JA",
	      "target_lang": "EN"
      }' | jq -r .translations[0].text
    fi
    
else
    echo "No APIKEY for DeepL API found. Create a file .deepl_apikey containing your apikey in the .config folder for this script $/.config/wl-translator"
fi

