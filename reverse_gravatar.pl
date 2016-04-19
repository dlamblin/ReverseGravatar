#!/usr/bin/perl
use warnings;
use strict;
use Digest::MD5 qw/md5_hex/;

my @g=qw/fe101e680f0f36bb6082086bbd65444f/;
my @n=qw/pastel lamblin/;
my @s=qw/_ . : ; ,/;
my @d=qw/gmail hotmail yahoo mailinator aol verizon speakeasy/;
my @t=qw/com net org edu co.uk fr/;

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

if ($#files >= 0) {
  parseFiles(@files);
}

print "Searching for: ", join(", ", @g), "\nWith:\n";

my %g;
foreach (@g) {
  $g{$_} = 1;
}
my @c=map{substr($_,0,1)} @n;
push @n, @c, "";
push @s, "";

foreach (@n, @s, @d, @t) {
  print "\"$_\"\n";
}

foreach my $fn (@n) {
  foreach my $ln (@n) {
    foreach my $s (@s) {
      if ($s ne "" && ($fn eq "" || $ln eq "")) {
        next;
      }
      foreach my $d (@d) {
        foreach my $t (@t) {
	  my $e="$fn$s$ln\@$d.$t";
	  my $m=md5_hex($e);
	  if (exists $g{$m}) {
	    print "$e => $m MATCHES!\n";
	  } else {
	    print "$e => $m\n";
	  }
	}
      }
    }
  }
}
