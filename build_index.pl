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

my $fn_lst = "/tmp/build_index_$$.lst";
qx(find . -name '*.[ch]' \! -type l > $fn_lst);
my $ctags_args = "-o newtags .";
if (!fork()) {
  exec("ctags $ctags_args -L $fn_lst; mv newtags tags");
}

qx(cscope -kbcq -i $fn_lst; rm -f $fn2);

wait();

close($fh1) or die "Couldn't close '$fn1' - $!";
close($fh2) or die "Couldn't close '$fn2' - $!";

