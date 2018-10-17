#!/usr/bin/perl

use strict;
use warnings;


my @lines = qx(grep -rni '\.$ARGV[0]\(\|\->.$ARGV[0]\(');
my $size = @lines;

printf "$size\n";

