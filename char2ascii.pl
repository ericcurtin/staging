#!/usr/bin/perl

use strict;
use warnings;

for(my $j = 0; $j < @ARGV; ++$j) {
  print("$ARGV[$j]\n");
  open my $fh, '<', $ARGV[$j] or die "error opening $ARGV[$j]: $!";
  my $str = do { local $/; <$fh> };
  for my $c (split //, $str) {
    my $ascii = ord($c);
    print("'$c' '$ascii'\n");
  }

  print("\n");
}

