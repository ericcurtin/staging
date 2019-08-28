#!/usr/bin/perl

use strict;
use warnings;

my $file = 'a.txt';
open my $info, $file or die "Could not open $file: $!";

my $i = 0;
my $j = 0;
while (1) {
while (my $line = <$info>)  {   
    print "$line\n";
    ++$i;
}
  if ($i > $j) {
  print "complete\n";
  $j = $i;
  }

  select(undef, undef, undef, .01);
}

close $info;


