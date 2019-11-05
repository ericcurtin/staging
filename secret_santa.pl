#!/usr/bin/perl

use strict;
use warnings;

my @BUCKET = @ARGV;

for my $i (@ARGV) {
  my $this_pick;
  do {
    $this_pick = int(rand(@BUCKET));
  } while ($i eq $ARGV[$this_pick]);


  qx(printf \"%s\" \"You got $ARGV[$this_pick]\n\" | mail -s \"Secret Santa\" -r \"$ARGV[0]\" $i);
}

