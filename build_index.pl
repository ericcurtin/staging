#!/usr/bin/perl

use strict;
use warnings;

use Fcntl ':flock';
use Cwd qw();
use File::Basename;

my $path = Cwd::cwd();

sub create_and_lock {
  my $fn = shift;

  if (!-e $fn) {
    open my $fh, ">", $fn or die "Couldn't open '$fn' - $!";
    close $fh or die "Couldn't close '$fn' - $!";
  }
}

my $fn1 = "$path/newtags";
create_and_lock($fn1);
open my $fh1, "<", $fn1 or die "Couldn't open '$fn1' - $!";
flock $fh1, LOCK_EX | LOCK_NB or die "Couldn't flock '$fn1' - $!";

my $fn2 = "$path/newcscope";
create_and_lock($fn2);
open my $fh2, "<", $fn2 or die "Couldn't open '$fn2' - $!";
flock $fh2, LOCK_EX | LOCK_NB or die "Couldn't flock '$fn2' - $!";

my $find_cmd = "find . -name '*.[ch]'";
my $ctags_args = "-o newtags .";
if (!fork()) {
  exec("ctags $ctags_args \$($find_cmd); mv newtags tags");
}

qx(cscope -kbcq \$($find_cmd); rm -f $fn2);

wait();

my $fn1_rem = $fn1 =~ s/\/home/\/emc/g;
$fn1_rem = basename($fn1_rem);
#qx(rsync $fn1 $fn2 emsdggprd03.isus.emc.com:$fn1_rem);

close($fh1) or die "Couldn't close '$fn1' - $!";
close($fh2) or die "Couldn't close '$fn2' - $!";

