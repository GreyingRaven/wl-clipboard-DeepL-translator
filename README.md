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

```sh
wl-paste -w sh ~/wl-clipboard-DeepL-translator/translate.sh
```

`wl-paste -w(--watch) command` allows for the execution of a command each time wl-copy is updated. This allows for the script to run on each new `copy` and call DeepL for a new translation

## To Do
- Add a flag to enable/disable translations containing time

## Changelog
[20250326] Added options [-h|f|s|t|T] h shows help; f sets translations file; s sets source language; t sets target language; T not implemented yet.
Added associative array stored in a translations file settable fith f option
