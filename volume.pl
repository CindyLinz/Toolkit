#!/usr/bin/env perl

use strict;
use warnings;

my $active;
my %status = map {
    my($volume, $power) = `amixer get $_` =~ /Playback \d+ \[(\d+)%\].*?\[(on|off)\]/;
    $_ => {volume => $volume, power => $power};
} qw(Master Speaker Headphone);
if( $status{Speaker}{volume} && !$status{Headphone}{volume} ) {
    $active = 'Speaker';
} else {
    $active = 'Headphone';
}

for( $ARGV[0] ){
    if( /toggle/ ) {
        if( $status{Master}{power} eq 'on' ) {
            system('amixer set Master off');
        }
        else {
            system('amixer set Master on');
            system("amixer set $active on");
        }
    }
    if( /up/ ) {
        system('amixer set Master on 5%+');
        system("amixer set $active on");
    }
    if( /down/ ) {
        system('amixer set Master on 5%-');
        system("amixer set $active on");
    }
}
