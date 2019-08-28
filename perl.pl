#!/usr/bin/perl

use strict;
use warnings;

my $file = 'a.txt';
open my $info, $file or die "Could not open $file: $!";

while (1) {
while (my $line = <$info>)  {   
    print "$line\n";
}
  print "complete\n";
  qx(inotifywait a.txt);
}

close $info;


