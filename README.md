#Reverse a Gravatar MD5 hash to an email address
I happened accross a Stack Overflow username that matches my lastname and has
my middle name as a first name. This seems uncommon, maybe we're related, maybe
there's an attempt to impersonate me, I'm leaning towards the former (but
loosely). So I grabbed the user's gravatar url and wrote the following
one-liner in perl. I've since edited it to make it a little less... public for
the person.

    $ perl -MDigest::MD5=md5_hex -e 'my $g="fe101e680f0f36bb6082086bbd65444f";print "Searching for: $g\nWith:\n";my @n=qw/pastel lamblin/;my @s=qw/_ , ./; my @d=qw/gmail hotmail yahoo mailinator aol verizon speakeasy/;my @t=qw/com net org edu co.uk fr/;my @c=map{substr($_,0,1)} @n;push @n,@c,"";push @s,"";foreach (@n,@s,@d,@t){print "::",$_,"::\n";} foreach my $fn (@n){foreach my $ln (@n){foreach my $s (@s){foreach my $d(@d){foreach my $t(@t){my $e="$fn$s$ln\@$d.$t";my $m=md5_hex($e); print"$e $m\n";print $e," => ",(($g eq $m)?"$m MATCHES!":$m),"\n";}}}}}'|grep MATCH
    pastel.lamblin@gmail.com => fe101e680f0f36bb6082086bbd65444f MATCHES!

That was kind of interesting to do. Didn't take too long, though I should have
just manually tried the, in retrospect, obvious greatest possibility.
