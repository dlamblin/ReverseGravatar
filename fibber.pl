#!/usr/bin/perl
use bigint;

my ($digits, $goal) = @ARGV;

sub fib {
    my ($a,$b) = (0,1);
    return sub {
        (my $r, $a, $b) = ($a, $b, $a+$b);
        return $r;
    };
}
my @d = (0) x $digits;
@d = map {fib();} @d;
my $count = 0;
for (my $i=0; $i<$digits; $i++) {
    print $d[$i]->() . "\n";
}
$d[1]->();
$d[2]->();
$d[2]->();
for (my $i=0; $i<$digits; $i++) {
    print $d[$i]->() . "\n";
}
