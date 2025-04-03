#!/bin/bash

##########################################################
# Help                                                   #
##########################################################
Help()
{
    # Display Help
    echo "Translates last copied text in clipboard using DeepL API."
    echo
    echo "Options: [h|f|s|t|c|R|S]"
    echo "-h    Print this help text."
    echo "-d    Enable debug mode. Shows debug log traces."
    echo "-v    Enable verbose mode. Shows more info per translation."
    echo "-f    Set translations file. (Default: ~/.config/wl-translator/.trasnlations)."
    echo "      To disable translations map point to non existing file."
    echo "-s    Set source_lang (Default: JA)."
    echo "-t    Set target_lang (Default: EN)."
    echo "-c    Enable clear flag. If enabled clears terminal each translation."
    echo "-r    Disable removal flag."
    echo "-S    Enable silent mode. Stops showing original text before translation."
}

##########################################################
# Get Translation                                        #
##########################################################
GetTranslation()
{
    # If translations file exists declare translations associative array
    if [ -f "$translations_file" ]; then
	declare -A translations
	source -- "$translations_file"
	translationhex=$(hexdump -ve '1/1 "%02x"' <<< "$1")
	if [[ -v translations[$translationhex] ]]; then
	    echo "|${translations[$translationhex]}"
            return 0
	fi
    fi
    # Check if there is an API key, only continue if there is
    if [ -f "$apikey_file" ]; then
	API_KEY=$(cat "$apikey_file")
	echo $1 > "$history_file"
	# Calls deepl free api and prints the translated text
	$verbose && echo "$1"
	translation_data="{ \"text\": [\"$1\"], \"source_lang\": \"$source_lang\", \"target_lang\": \"$target_lang\" }"
	$debug && echo "DEBUG: $translation_data"
	deepl_response=$(curl --silent -X POST https://api-free.deepl.com/v2/translate   --header "Content-Type: application/json"   --header "Authorization: DeepL-Auth-Key $API_KEY"   --data "$translation_data")
	$debug && echo "DEBUG: $deepl_response"
	translation=$(jq -r ".translations[].text" <<< "${deepl_response}")
	echo "$translation"
	# If translations file exists save translation to associative array and persist in file
	if [ -f "$translations_file" ]; then
	    translations["$translationhex"]="$translation"
	    declare -p translations > "$translations_file"
	fi
    else
	echo "No APIKEY for DeepL API found. Create a file .deepl_apikey containing your apikey in the .config folder for this script $/.config/wl-translator"
    fi
}

##########################################################
# Initialize valiables                                   #
##########################################################
# Create config folder
mkdir -p "$HOME/.config/wl-translator"
# Set file varibles
history_file="$HOME/.config/wl-translator/.last_translation"
# Create history file
touch "$history_file"
translations_file="$HOME/.config/wl-translator/.translations"
apikey_file="$HOME/.config/wl-translator/.deepl_apikey"
# Set flags
remove_flag=true
clear_flag=false
silent=false
debug=false
verbose=false
# Set line removal regexes
money_regex='/^.*[0-9]Lo.*$/d'
time_regex='/^.*[0-9]{2}[-:][0-9]{2}[-:][0-9]{2}.*$/d'
zp_regex='/^.*[0-9]ZP/d'
mp_regex='/[0-9]*MP/d'
hp_regex='/[0-9]*HP/d'
# Set default languages
source_lang="JA"
target_lang="EN"


###########################################################
# Main program                                            #
###########################################################
#----------------------------------------------------------
# Get the options                                         #
#----------------------------------------------------------

while getopts :f:s:t:rhcsdv flag
do
    # debug - echo "DEBUG: $flag"
    case "${flag}" in
	h) # display help
	    echo "testing help option"
	    Help
	    exit;;
	d) # enable debug mode
	    debug=true;;
	v) # enable verbose mode
	    verbose=true;;
	f) # set translations file
	    translations_file=${OPTARG};;
	s) # set source_lang
	    source_lang=${OPTARG};;
	t) # set target_lang
	    target_lang=${OPTARG};;
	c) # set clear flag
	    clear_flag=true;;
	r) # set removal flag
	    remove_flag=false;;
	S) # set silent flag
	    silent=true;;
	\?) # Invalid option
	    echo "Error: Invalid option"
	    exit;;
    esac    
done

#----------------------------------------------------------
# Get text and check if translatable                      #
#----------------------------------------------------------

# Asign text to translate from input
raw_text="$(wl-paste)"
# Clean translate string to remove API errors
## remove 「」characters, remove \r, exchange " for \", exchange ! for !\n
translate_text="$(sed -e 'H;${x;s/「//g;s/」//g;s/\r//g;s/"/\\"/g;s/！/!\n/g;p;};d' <<< "$raw_text")"
# If remove_flag active remove removal regexes from translation string
if $remove_flag ; then 
    translate_text=$(sed $money_regex <<< "$translate_text")
    translate_text=$(sed $time_regex <<< "$translate_text")
    translate_text=$(sed $zp_regex <<< "$translate_text")
    translate_text=$(sed $mp_regex <<< "$translate_text")
    translate_text=$(sed $hp_regex <<< "$translate_text")
fi
# Clean terminal from previous translations
$clear_flag && clear
# Show original text before translation if not silent mode
$silent || echo "$translate_text"
$silent || echo "-"
# Extract array from translate_text
readarray -t translate_array <<< "$translate_text"
$debug && echo "DEBUG: " ; $debug && declare -p translate_array
for element in "${translate_array[@]}"
do
    $verbose && echo "$element"
    if [ ! -z "$element" ] && [[ $element =~ [0-9]+ ]] ;
    then
	aux="$element"
	extracted_numbers=$(echo "$element" | grep -o -E '[0-9]*+')
	$debug && echo "DEBUG: line numbers: $extracted_numbers"
	readarray -t numbers <<< "$extracted_numbers"
	for number in "${numbers[@]}"
	do
	    $debug && echo "DEBUG: n: $number"
	    aux="$(sed -e "s/${number}/#/" <<< "$aux")"
	    $debug && echo "DEBUG: aux: $aux"
	done
	aux="$(GetTranslation "$aux")"
	for number in "${numbers[@]}"
	do
	    aux="$(sed -e "s/#/${number}/" <<< "$aux")"
	done
	echo "$aux"
    else
	$debug && echo "DEBUG: No number"
	GetTranslation "$element"
    fi
done
