#!/usr/bin/perl

use feature qw(:5.18);
use warnings;
use strict;

use List::Util ('shuffle');
use Data::Dumper::Concise;

use constant INPUT_SIZE => 1500;

my @data = (1 .. INPUT_SIZE);
my %trials = (
        Sorted_Data   => [@data],
        Reverse_Data  => [reverse @data],
        Shuffled_Data => [shuffle @data],
);

my %methods = (
        Quicksort_Lomuto => \&quicksorts::Lomuto,
        Quicksort_Hoare  => \&quicksorts::Hoare,
);

for my $method (sort keys %methods) {
        for my $trial (sort keys %trials) {
                printf "%19s %-15s", $method, $trial;
                my @result = $methods{$method}->(@{$trials{$trial}});
                my ($excalls, $qscalls) = (pop @result, pop @result);
                printf "Recursions: %7d Swaps: %7d\n", $qscalls, $excalls;
                if (16 >= INPUT_SIZE) {
                        say join(',', @{$trials{$trial}}),
                            ' => ',
                            join(',', @result);
                }
        }
}

package quicksorts;
sub Lomuto (@) {
        # For the subroutines to modify the input they must be anonymous
        my @in = @_;
        my @q = ($#in, 0);
        my $qscalls = 0;
        my $excalls = 0;
        # Exchange (swap) indexed values.
        my $ex = sub ($$) {
                ($in[$_[0]], $in[$_[1]]) = ($in[$_[1]], $in[$_[0]]);
                $excalls++;
        };
        # Lomuto Partition
        #   subarray from p to r into p to i - 1, i, and i + 1 to r
        my $part = sub ($$) {
                my ($p, $r) = @_;
                my ($x, $i) = ($in[$r], $p - 1);
                for (my $j = $p; $j < $r; $j++) {
                        if ($in[$j] <= $x) {
                                $ex->(++$i, $j);
                        }
                }
                $ex->(++$i, $r);
                return $i;
        };
        # Quicksort subarray from p to r by partioning in two and sorting each.
        # For anonymous subroutines to call themselves they must:
        # use __SUB__ or a Y-Combinator.
        # HOWEVER perl doesn't like recursing beyond 100 times on 1000 elements
        my $qs = sub {
                my ($p, $r) = @_;
                $qscalls++;
                if ($p < $r) {
                        my $q = $part->($p, $r);
                        # Idealy this would be recursive like:
                        # __SUB__->($p, $q-1);
                        # __SUB__->($q+1, $r);
                        # Instead we push future parameters onto our own queue
                        push @q, $r, $q + 1, $q - 1, $p;
                }
        };
        # Idealy recursive call would be: $qs->(0, $#in);
        while ($#q > 0) {
                $qs->(pop @q, pop @q);
        }
        return @in, $qscalls, $excalls;
}

# This would have the same comments as the previous sub quicksort except $part
sub Hoare (@) {
        my @in = @_;
        my @q = ($#in, 0);
        my $qscalls = 0;
        my $excalls = 0;
        my $ex = sub ($$) {
                ($in[$_[0]], $in[$_[1]]) = ($in[$_[1]], $in[$_[0]]);
                $excalls++;
        };
        # Hoare Partition
        #   subarray from p to r into p to j, and j + 1 to r
        # note the lack of a middle pivot value
        my $part = sub ($$) {
                my ($p, $r) = @_;
                my ($x, $i, $j) = ($in[$p], $p - 1, $r + 1);
                while (1) {
                        do {$j--} until ($in[$j] <= $x);
                        do {$i++} until ($in[$i] >= $x);
                        if ($i < $j) {
                                $ex->($i, $j);
                        } else {
                                return $j;
                        }
                }
        };
        my $qs = sub {
                my ($p, $r) = @_;
                $qscalls++;
                if ($p < $r) {
                        my $q = $part->($p, $r);
                        push @q, $r, $q + 1, $q, $p; # NOT $r, $q+1, $q-1, $p
                }
        };
        while ($#q > 0) {
                $qs->(pop @q, pop @q);
        }
        return @in, $qscalls, $excalls;
}
1;
