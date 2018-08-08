#!/usr/bin/perl

use strict;
use warnings;
use feature qw(say);

my($pid, @cmd) = @ARGV;

if( !$pid || !@cmd ) {
    say "usage ./run_after.pl pid command...";
    exit 1;
}

if( !kill(0, $pid) ) {
    say "process $pid doesn't exist.";
    exit 1;
}

say "process $pid is running, keep an eye on it...";
{
    if( !kill(0, $pid) ) {
        say "process $pid ended. RUN @cmd!";
        system("@cmd");
        exit 0;
    }
    select undef, undef, undef, .1;
    redo;
}
