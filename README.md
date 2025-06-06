# Bash translator with DeepL

Using wl-paste --watch and DeepL's free api it catches the copy updates and calls DeepL to translate the new text.

```sh
export API_KEY={Your_key_goes_here...}

curl -X POST https://api-free.deepl.com/v2/translate   --header "Content-Type: application/json"   --header "Authorization: DeepL-Auth-Key $API_KEY"   --data '{
    "text": ["Hello world!"], 
    "target_lang": "DE"
}'
```

## How to use
`wl-paste -w(--watch) command` allows for the execution of a command each time wl-copy is updated. This allows for the script to run on each new `copy` and call DeepL for a new translation

The script will create a config folder in `~/.config/wl-translator` containing default hidden files for normal use:
- `.last_translation` Used to prevent translating the same string twice in a row
- `.translations` Map of translations to reduce the number of calls to DeepL api, if it has already been translated it recovers translation from this file.

**Important**: This folder must contain `.deepl_apikey` file with a valid DeepL api key.

To run the script use the following command:
```sh
wl-paste -w sh ~/wl-clipboard-DeepL-translator/translator.sh wl-paste
```
Options can be added at the end of the command:
```sh
wl-paste -w sh ~/wl-clipboard-DeepL-translator/translator.sh wl-paste -f ~/Documents/translations/rus2eng.translations -s RU -t EN
```
#### Available options:
 - h    Print help text.[Not Working]
 - d    Enable debug mode. Shows debug log traces.
 - v    Enable verbose mode. Shows more info per translation.
 - f    Set translations file. (Default: ~/.config/wl-translator/.trasnlations).
        To disable translations map point to non existing file.
 - s    Set source_lang (Default: JA).
 - t    Set target_lang (Default: EN).
 - c    Enable clear flag. Clears terminal before each translation
 - R    Disable removal flag.
 - S    Enable silent mode. Stops showing original text before translation.

For easier use create a symling to ~/.local/bin
```
ln -s ~/wl-clipboard-DeepL-translator/translator.sh ~/.local/bin/translate
wl-paste -w translate wl-paste
```


## To Do
1. Make removal regexes configurable.
2. Remove wl-paste dependency.

## Changelog
### [20250403]
##### Added silent mode
##### Added verbose mode
##### Added debug mode
##### Changed logic to work with string[]
 1. Split translation text into translation array by lines
 2. Call GetTranslation() for each line
 - Better history managment
##### Numbers in translation text managed
 - Any text with numbers will send # instead so it can be saved in history and reused
 - `3 foo and 4 bar` will call to deepl and translate `# foo and # bar`
 - `2 foo and 7 bar` will use saved translation.
##### Removed exclusion regex
 - Unnecesary as removal regex takes care of it
##### Added clear flag
 - Disable by using -c flag
 - If true clears terminal each translation
##### Added LR after !
 - Creates a new line that can be translated separately.
##### Fixed " in string translation error
##### Fixed help not showing
### [20250331] Fix
##### Added wl-paste dependency
 - Wasn't working as intended
### [20250329] Unimplemented functionality
##### Removed wl-paste dependency
 - translator.sh now takes an input string to translate
##### New bash. update_translation.sh
 - Takes a file as parameter
 1. Prompts user to input translation to update key
 2. Prompts uset to input new translation
##### Implemented exclude flag.
 1. Default true.
 2. If active stops translation if it includes excluding regexes:
  - Excludes strings containing time [00:00:00]
  - Excludes combat strings containing health/mana/zp values
##### Implemented remove flag.
 1. Default true.
 2. If active removes lines from translation string that include remove regexes:
  - Removes money lines [####Lo]
##### Removed option T. 
##### Added options [E|R] 
 1. E sets exclude flag.
 2. R sets remove flag.
##### Updated How to use.
##### Formatted changelog for easier reading.

### [20250326] Configurable options
##### Added options [-h|f|s|t|T] 
 1. h shows help; 
 2. f sets translations file; 
 3. s sets source language; 
 4. t sets target language; 
 5. T not implemented yet.
##### Added associative array stored in a translations file settable fith f option
