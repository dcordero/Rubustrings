# Rubustrings

A format validator for Localizable.strings files.

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

## Future validators to include:

* Warning on untranslated strings
* Warning if the translation is significatly larger than the original string.

## License

MIT License (MIT) Copyright (c) 2014 @dcordero
