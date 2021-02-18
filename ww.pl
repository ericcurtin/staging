#!/usr/bin/perl

use strict;
use warnings;

use Fcntl ':flock';
use Linux::Prctl qw(set_pdeathsig);
use POSIX qw(WNOHANG);

my $usr = qx(id -un);
chomp($usr);

my $file = ".ww.log";
qx(> $file);
open my $self, '<', "$file" or die "Couldn't open self: $!";
flock $self, LOCK_EX | LOCK_NB or die "This script is already running";

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

my $max_user_watches = qx(sysctl -n fs.inotify.max_user_watches);
my $cur_user_watches = qx(cat /proc/*/fdinfo/* 2> /dev/null | grep -c "^inotify");
my $needed_user_watches = qx(find . -name "*.[c|h]" | wc -l);
my $available_user_watches = $max_user_watches - $cur_user_watches;

#print("max_user_watches: $max_user_watches" .
#      "cur_user_watches: $cur_user_watches" .
#      "needed_user_watches: $needed_user_watches" .
#      "available_user_watches: $available_user_watches\n");

if ($needed_user_watches > $available_user_watches) {
  qx(echo "We need more watches ($needed_user_watches) than available ($available_user_watches)\n" > $file);
  return 1;
}

fork_exec();

open my $info, $file or die "Could not open $file: $!";

while (1) {
  qx(/home/$usr/git/pub/staging/build_index.pl; inotifywait -q $file);
}

close($info);

