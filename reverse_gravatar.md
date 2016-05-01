# Reverse Gravatar

Reverse Gravatar is intended to effectively reverse MD5 hashes to the email
address from which the sum was generated. As the MD5 hash algorithm is
designed to be irreversible, I accomplish this by the classically simple
approach of generating reasonable candidate data to hash and then comparing the
resulting hash against all the known valid hashes. Any match indicates that we
know the data which was hashed.

The candidate data for Gravatar hashes are email addresses, and for current
purposes these are reasonably guessed to be in a limited set of domains, and
optionally include a separator of underscore, period, colon, semicolon, or
comma. These may not always follow the exact allowed characters of the
RFC in question.

## How to pass data to this program

This program reads whitespace separated strings of input from the command line
arguments. If any of these are valid file path descriptors, these are opened
and read for their content. All the remaining arguments, and the
file contents, are then split on whitespace, and either assumed to form name
portions of an email address or, only if they are 32 characters of lowercase
hexadecimal, to be MD5 hashes. When no arguments are specified the program
instead processes standard in as it would a file (as just described).

The program tries all combinations of names, the first character of
names, from 1 to 3 parts with every and no separator, followed by @
and every possible domain (from an internal list) with . and every possible
domain ending (from an internal list).

These lists are:

### Separators

`_` `.` `:` `;` `,`

### Domains

`gmail` `hotmail` `yahoo` `mailinator` `aol` `verizon` `speakeasy`

### Domain endings

`com` `net` `org` `edu` `co.uk` `fr`

## Example usage

`reverse_gravatar.pl daniel pastel lamblin fe101e680f0f36bb6082086bbd65444f
reverse_gravatar.pl sampleInput.txt 2>/dev/null`
