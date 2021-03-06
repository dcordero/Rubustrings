# Rubustrings [![Build Status](https://travis-ci.org/dcordero/Rubustrings.svg?branch=master)](https://travis-ci.org/dcordero/Rubustrings)

Check the format and consistency of the Localizable.strings files of iOS Apps with multi-language support

[Rubustrings](https://github.com/dcordero/RubustringsXml) is also available for Android [here](https://github.com/dcordero/RubustringsXml)

## Usage

It only needs the files to validate as arguments

```
rubustrings Localizable.strings
```

Additionally to the filenames, including the option --onlyformat will only assert for the format.

## Install

```
gem install rubustrings
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
dcordero@silver:~$ rubustrings Localizable.strings
Processing file: "Localizable.strings"

Localizable.strings:217: error: beginning mismatch: "Tubasa" = " Tubasa";
Localizable.strings:220: error: number of variables mismatch: "Web %@" = "Web";
Localizable.strings:225: error: invalid format: "bad format" = "because of a missing quote;

Result: ✘ Some errors detected
```

```
dcordero@silver:~$ rubustrings Localizable.strings
Processing file: "Localizable.strings"

Result: ✓ Strings file validated succesfully
```
## XCode

Rubustrings can also be used as a custom build rule so that all .strings files
are automatically validated at build time. This will also attempt to highlight
offending lines in XCode.

![Xcode build rule example](./xcode_example.png "example")

Just add a new "Run Script Phase" with:

```
if which rubustrings>/dev/null; then
  find "${SRCROOT}" -type f -name Localizable.strings -print0 | xargs -0 -n1 rubustrings
else
  echo "warning: Rubustrings not installed, download from https://github.com/dcordero/Rubustrings"
fi
```

![Xcode setting example](./xcode_setting.png "configuration")

## License

MIT License (MIT) Copyright (c) 2017 @dcordero
