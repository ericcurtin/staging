#!/usr/bin/perl

use strict;
use warnings;

use Scalar::Util qw(looks_like_number);

my $size = $ARGV[0];
my $letter = substr($ARGV[0], -1);

if (!looks_like_number($letter)) {
  chop($size);
  if ($letter eq "k") {
    $size *= 1024;
  }
  elsif ($letter eq "m") {
    $size *= 1024 * 1024;
  }
  elsif ($letter eq "g") {
    $size *= 1024 * 1024 * 1024;
  }
}

$size = sprintf("%d", $size);

exit(system("cat /dev/urandom | head -c $size > $ARGV[1]"));

