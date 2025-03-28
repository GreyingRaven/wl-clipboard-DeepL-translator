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
wl-paste -w sh ~/wl-clipboard-DeepL-translator/translate.sh
```
Options can be added at the end of the command:
```sh
wl-paste -w sh ~/wl-clipboard-DeepL-translator/translate.sh -f ~/Documents/translations/rus2eng.translations -s RU -t EN
```
#### Available options:
 - h    Print help text.
 - f    Set translations file. (Default: ~/.config/wl-translator/.trasnlations).
        To disable translations map point to non existing file.
 - s    Set source_lang (Default: JA).
 - t    Set target_lang (Default: EN).
 - T    Enable/Disable excludion flag (Default: Enabled)[true|false].
 - R    Enable/Disable removal flag (Default: Enabled)[true|false].


## To Do
- Editable history translations
 - Allow input after translation to update?
 - Auxiliary script to update saved translations?

## Changelog
[20250329] Unimplemented functionality
- Implemented exclude flag.
 - Default true.
 - If active stops translation if it includes excluding regexes:
  - Excludes strings containing time [00:00:00]
  - Excludes combat strings containing health/mana/zp values
- Implemented remove flag.
 - Default true.
 - If active removes lines from translation string that include remove regexes:
  - Removes money lines [####Lo]
- Removed option T. 
- Added options [E|R] 
 - E sets exclude flag.
 - R sets remove flag.
- Updated How to use.
- Formatted changelog for easier reading.

[20250326] Configurable options
- Added options [-h|f|s|t|T] 
 - h shows help; 
 - f sets translations file; 
 - s sets source language; 
 - t sets target language; 
 - T not implemented yet.
- Added associative array stored in a translations file settable fith f option
