#!/usr/bin/perl
use XML::SAX;

my $parser = XML::SAX::ParserFactory->parser(
    Handler => TestXMLDeduplication->new()
);

my $ret_ref = $parser->parse_file(\*TestXMLDeduplication::DATA);
close(TestXMLDeduplication::DATA);

print "\n\nDuplicates skipped: ", $ret_ref->{skipped}, "\n";
print "Duplicates cut: ", $ret_ref->{cut}, "\n";

package TestXMLDeduplication;
use base qw(XML::SAX::Base);

my $inUserinterface;
my $inUpath;
my $upathSeen;
my $defaultOut;
my $currentOut;
my $buffer;
my %seen;
my %ret;

sub new {
    # Idealy STDOUT would be an argument
    my $type = shift;
    #open $defaultOut, '>&', STDOUT or die "Opening STDOUT failed: $!";
    $defaultOut = *STDOUT;
    $currentOut = $defaultOut;
    return bless {}, $type;
}

sub start_document {
    %ret = ();
    $inUserinterface = 0;
    $inUpath = 0;
    $upathSeen = 0;
}

sub end_document {
    return \%ret;
}

sub start_element {
    my ($self, $element) = @_;

    if ('userinterface' eq $element->{Name}) {
      $inUserinterface++;
      %seen = ();
    }
    if ('upath' eq $element->{Name}) {
      $buffer = q{};
      undef $currentOut;
      open($currentOut, '>>', \$buffer) or die "Opening buffer failed: $!";
      $inUpath++;
    }

    print $currentOut '<', $element->{Name};
    print $currentOut attributes($element->{Attributes});
    print $currentOut '>';
}

sub end_element {
    my ($self, $element) = @_;

    print $currentOut '</', $element->{Name};
    print $currentOut '>';

    if ('userinterface' eq $element->{Name}) {
      $inUserinterface--;
    }

    if ('upath' eq $element->{Name}) {
      close($currentOut);
      $currentOut = $defaultOut;
      # Check if what's in upath was seen (lower-cased)
      if ($inUserinterface && $inUpath) {
	if (!exists $seen{lc($buffer)}) {
          print $currentOut $buffer;
	} else {
	  $ret{skipped}++;
	  $ret{cut} .= $buffer;
	}
	$seen{lc($buffer)} = 1;
      }
      $inUpath--;
    }
}

sub characters {
    # Note that this also capture indentation and newlines between tags etc.
    my ($self, $characters) = @_;

    print $currentOut $characters->{Data};
}

sub attributes {
    my ($attributesRef) = @_;
    my %attributes = %$attributesRef;

    foreach my $a (values %attributes) {
        my $v = $a->{Value};
	  # See also XML::Quote
	  $v =~ s/&/&amp;/g;
	  $v =~ s/</&lt;/g;
	  $v =~ s/>/&gt;/g;
	  $v =~ s/"/&quot;/g;
	print $currentOut ' ', $a->{Name}, '="', $v, '"';
    }
}

__DATA__
  <package>
    <id>1523456789</id>
    <models>
      <model type="A">
        <start>2016-04-20</start>   
        <end>2017-04-20</end>    
      </model>
      <model type="B">                 
        <start>2016-04-20</start>     
        <end>2017-04-20</end>        
      </model>
    </models>
    <userinterface>
      <upath>/Example/Dir/Here</upath>
      <upath>/Example/Dir/Here2</upath>
      <upath>/example/dir/here</upath>   
    </userinterface>
    <userinterface>
      <upath>/Example/Dir/<b>Here</b></upath> <upath>/Example/Dir/Here2</upath>
      <upath>/example/dir/<b>here</b></upath>   
    </userinterface>
  </package>

