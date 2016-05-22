# Rubustrings [![Build Status](https://travis-ci.org/dcordero/Rubustrings.svg?branch=master)](https://travis-ci.org/dcordero/Rubustrings)

Check the format and consistency of the Localizable.strings files of iOS Apps with multi-language support

[Rubustrings](https://github.com/dcordero/RubustringsXml) is also available for Android [here](https://github.com/dcordero/RubustringsXml) 

## Usage

It only needs the files to validate as arguments

```
./rubustrings Localizable.strings
```

## Validators

Currently Rubustrings validates:

* **The syntaxis of the strings file**: Just the format of each line: "key" = "value";
* **Dynamic values (%@, %d, %ld,...)**: It checks that the translation include the same set of them than the original string.
* **Special characters at the beginning or at the end**: If the original string begins or ends with a white space,\n or \r it tests that the translation also does.

It also warning on:
* **Untranslated strings**: In missing translations
* **Translation significantly large**: In translations 3 times larger than original string

## Example

```
dcordero@silver:~$ ./rubustrings Localizable.strings
Processing file: "Localizable.strings"

✘ Beginning mismatch: " Tubasa" = "Tubasa";
✘ Invalid format: "bad format" = "because of a missing quote;
✘ Number of variables mismatch: "Web %@" = "Web";

✘ Some errors detected
```

```
dcordero@silver:~$ ./rubustrings Localizable.strings
Processing file: "Localizable.strings"
✓ Strings file validated succesfully
```

## License

MIT License (MIT) Copyright (c) 2014 @dcordero
