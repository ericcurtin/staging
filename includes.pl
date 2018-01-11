#!/usr/bin/perl

use strict;
use warnings;

if (@ARGV == 1) {
    push(@ARGV, `git status | grep "hpp\\|cpp" | sed 's/modified://' | xargs`);
}

for(my $j = 1; $j < @ARGV; ++$j) {
    my @lines = `grep -n "#inc\\|using" $ARGV[$j] | cut -d: -f1`;
    for my $i (@lines) {
        chomp($i);
        system("sed -i '${i}i///////includeCHECK' $ARGV[$j]");
        system("sed -i '${i}{N;s" . '/\n//' . ";}' $ARGV[$j]");

        if (!system("$ARGV[0] > /dev/null 2>&1")) {
            printf("$ARGV[$j]:$i unneccessary");
            exit;
        }
        system("sed -i 's#///////includeCHECK##' $ARGV[$j]");
    }
}

printf("All good!\n");

