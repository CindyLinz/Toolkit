#!/usr/bin/env perl

use strict;
use warnings;

use Time::HiRes qw(time);

$| = 1;
{
    my $now = time;
    my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime $now;
    printf "\r%d.%d.%d %02d:%02d:%02d", $year+1900, $mon+1, $mday, $hour, $min, $sec;
    select undef, undef, undef, 1.001 - ($now - int $now);
    redo;
}
