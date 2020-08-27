#!/usr/bin/perl

use strict;
use warnings;

use Fcntl ':flock';
use Linux::Prctl qw(set_pdeathsig);
use POSIX qw(WNOHANG);

my $usr = qx(id -un);
chomp($usr);
open my $self, '<', "/home/$usr/git/staging/ww.pl" or die "Couldn't open self: $!";
flock $self, LOCK_EX | LOCK_NB or die "This script is already running";

my $file = "/var/log/workspacewatcher.log";
my $SIGTERM = 15;

my $num_of_chld = 0;

$SIG{CHLD} = sub {
  --$num_of_chld;
  while (waitpid(-1, WNOHANG) > 0) {
  }
};

sub fork_exec {
  my $pid = fork();
  if (!$pid) {
    set_pdeathsig($SIGTERM);

    my $events = "close_write,moved_to";
    exec("inotifywait -m -e $events --include \".c\$|.h\$\" -r . > $file");
  }
  elsif ($pid < 0) {
    die("fork failed\n");
  }
}

qx(> $file);
fork_exec();

open my $info, $file or die "Could not open $file: $!";

while (1) {
  qx(/home/curtie2/git/pub/staging/build_index.pl; inotifywait -q $file);
}

close($info);

