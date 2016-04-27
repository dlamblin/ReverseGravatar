#Reverse a Gravatar MD5 hash to an email address
I happened accross a Stack Overflow username that matches my lastname and has
my middle name as a first name. This seems uncommon, maybe we're related, maybe
there's an attempt to impersonate me, I'm leaning towards the former (but
loosely). So I grabbed the user's gravatar url and wrote the following
one-liner in perl. I've since edited it to make it a little less... public for
the person.

```shell
$ perl -MDigest::MD5=md5_hex -e 'my$g="fe101e680f0f36bb6082086bbd65444f";'\
'print"Searching for: $g\nWith:\n";my@n=qw/first last/;my@s=qw/_ , ./;'\
'my@d=qw/gmail hotmail yahoo mailinator aol verizon speakeasy/;my@t='\
'qw/com net org edu co.uk fr/;my@c=map{substr($_,0,1)}@n;push@n,@c,"";push'\
'@s,"";foreach(@n,@s,@d,@t){print"::",$_,"::\n";}foreach my$fn(@n){foreach'\
'my$ln(@n){foreach my$s(@s){foreach my$d(@d){foreach my$t(@t){my'\
'$e="$fn$s$ln\@$d.$t";my$m=md5_hex($e);print"$e $m\n";print$e," => ",'\
'(($g eq $m)?"$m MATCHES!":$m),"\n";}}}}}'|grep MATCH
firstlast@gmail.com => fe101e680f0f36bb6082086bbd65444f MATCHES!
```


That was kind of interesting to do. Didn't take too long, though I should have
just manually tried the, in retrospect, obvious greatest possibility.

##More than one-liner
This was copied out into [`reverse_gravatar.pl`](reverse_gravatar.pl) and
support for mixed files and args was added and it was fixed to avoid repetition,
support middle names or initials, etc. Perhaps the one-liner is easier to read
with highlighting:

```perl
my$g="fe101e680f0f36bb6082086bbd65444f";
print"Searching for: $g\nWith:\n";my@n=qw/first last/;my@s=qw/_ , ./;
my@d=qw/gmail hotmail yahoo mailinator aol verizon speakeasy/;my@t=
qw/com net org edu co.uk fr/;my@c=map{substr($_,0,1)}@n;push@n,@c,"";push
@s,"";foreach(@n,@s,@d,@t){print"::",$_,"::\n";}foreach my$fn(@n){foreach
my$ln(@n){foreach my$s(@s){foreach my$d(@d){foreach my$t(@t){my
$e="$fn$s$ln\@$d.$t";my$m=md5_hex($e);print"$e $m\n";print$e," => ",
(($g eq $m)?"$m MATCHES!":$m),"\n";}}}}}
```

##Java implementation
I also wrote a java version ([`ReverseGravatar.java`](ReverseGravatar.java))
which, due to JVM start up, may seem slower, but should process larger inputs
faster. The timing of the implementations is still to be done, write to me if
you've measured this, particularly if the two methods of getting an MD5 hash
string in my class were compared as well.
