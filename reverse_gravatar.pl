#!/usr/bin/perl

=head1 Reverse Gravatar

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

=head2 How to pass data to this program

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

=head3 Separators

_ . : ; ,

=head3 Domains

gmail hotmail yahoo mailinator aol verizon speakeasy

=head3 Domain endings

com net org edu co.uk fr

=head2 Example usage

reverse_gravatar.pl daniel pastel lamblin fe101e680f0f36bb6082086bbd65444f
reverse_gravatar.pl sampleInput.txt 2>/dev/null

=cut

use warnings;
use strict;
use Digest::MD5 qw/md5_hex/;

my @g=qw//;
my @n=qw//;
my @s=qw/_ . : ;/;
my @d=qw/gmail hotmail yahoo mailinator aol verizon speakeasy/;
my @t=qw/com net org edu co.uk fr/;

# blank seperator and comma
push @s, "", ",";

sub parseArgOrLine {
  shift;
  chomp;
  foreach (split) {
    if (/^[0-9a-f]{32}$/) {
      push @g, $_;
    } else {
      push @n, $_;
    }
  }
}

my @files;
foreach (@ARGV) {
  if (-e $_) {
    push @files, $_;
  } else {
   parseArgOrLine($_);
  }
}

sub parseFiles (@) {
  local @ARGV = @_;
  while(<>) {
    parseArgOrLine($_);
  }
}

if ($#files >= 0 || $#ARGV < 0) {
  parseFiles(@files);
}

print "Searching for: ", join(", ", @g), "\nWith:\n";

# Index hashes
my %g;
foreach (@g) {
  $g{$_} = 1;
}

# name initials and blank name part
my @c=map{substr($_,0,1)} @n;
push @n, @c, "";

# Unique names
my %c;
foreach (@n) {
  $c{$_} = 1;
}
@n = keys %c;

foreach (@n, @s, @d, @t) {
  print "\"$_\"\n";
}

foreach my $fn (@n) {
  if ("" eq $fn) {
    next; # Always minimum 1 name.
  }
  foreach my $mn (@n) {
    foreach my $ln (("" eq $mn) ? "" : @n) {
      foreach my $s (("" eq $mn) ? "" : @s) {
        foreach my $d (@d) {
          foreach my $t (@t) {
            my $e;
            if ($mn ne "") {
              $e = "$fn$s$mn";
            } else {
              $e = "$fn";
            }
            if ($ln ne "") {
              $e .= "$s$ln"
            }
            $e .= "\@$d.$t";
            my $m=md5_hex($e);
            if (exists $g{$m}) {
              print STDOUT "Hash: $m <= Email: $e MATCHES!\n";
            } else {
              print STDERR "Hash: $m <= Email: $e\n";
            }
          }
        }
      }
    }
  }
}
