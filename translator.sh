#!/bin/bash

##########################################################
# Help                                                   #
##########################################################
Help()
{
    # Display Help
    echo "Translates last copied text in clipboard using DeepL API."
    echo
    echo "Options: [-h|f|s|t|T]"
    echo "h    Print this help text."
    echo "f    Set translations file."
    echo "s    Set source_lang (Default: JA)."
    echo "t    Set target_lang (Default: EN)."
    echo "T    Translate text containing time (Default: False)."
}


##########################################################
# Initialize valiables                                   #
##########################################################
# Create config folder
mkdir -p "$HOME/.config/wl-translator"
# Set file varibles
history_file="$HOME/.config/wl-translator/.last_translation"
translations_file="$HOME/.config/wl-translator/.translations"
apikey_file="$HOME/.config/wl-translator/.deepl_apikey"
# Set time exclusion regex
time_regex='^.*[0-9]{2}[-:][0-9]{2}[-:][0-9]{2}.*$'
# Set default languages
source_lang="JA"
target_lang="EN"



###########################################################
# Main program                                            #
###########################################################
# Get the options
while getopts :h:f:s:t:T: flag
do
    case "${flag}" in
	h) # display help
	    Help
	    exit;;
	f) # set translations file
	    translations_file=${OPTARG};;
	s) # set source_lang
	    source_lang=${OPTARG};;
	t) # set target_lang
	    target_lang=${OPTARG};;
	T) # set flag for time condition
	    echo "Option not implemented"
	    exit;;
	\?) # Invalid option
	    echo "Error: Invalid option"
	    exit;;
    esac
done
# Check if there is something saved as a previous text to translate
if [ -f "$history_file" ]; then
    last_translation=$(cat "$history_file")
fi
# Declare translations associative array
if [ -f "$translations_file" ]; then
    declare -A translations
    source -- "$translations_file"
fi
# Asign text to translate from clipboard
translate_text="$(wl-paste)"
translationhex=$(hexdump -ve '1/1 "%02x"' <<< "$translate_text")
if [[ -v translations[$translationhex] ]]; then
    clear
    echo "hex: $translationhex"
    echo "$translate_text"
    echo "-"
    echo "${translations[$translationhex]}"
    exit
fi
# Check if there is an API key, only continue if there is
if [ -f "$apikey_file" ]; then
    API_KEY=$(cat "$apikey_file")

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
	echo "$source_lang -> $target_lang"
	printf $translate_text
	printf '\n
-
    \n'
	# Calls deepl free api and prints the translated text
	deepl_response=$(curl --silent -X POST https://api-free.deepl.com/v2/translate   --header "Content-Type: application/json"   --header "Authorization: DeepL-Auth-Key $API_KEY"   --data '
      {
	      "text": ["'$translate_text'"],
	      "source_lang": "'$source_lang'",
	      "target_lang": "'$target_lang'"
      }')
	translation=$(jq -r ".translations[0].text" <<< "${deepl_response}")
	echo "$translation"
	# Save translation to associative array and persist in file
	translations["$translationhex"]="$translation"
	declare -p translations > "$translations_file"
    fi
    
else
    echo "No APIKEY for DeepL API found. Create a file .deepl_apikey containing your apikey in the .config folder for this script $/.config/wl-translator"
fi

