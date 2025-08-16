#!/usr/bin/env perl
use strict;
use warnings;
use feature qw(say);

use EV;
use AE;
use AnyEvent;
use AnyEvent::Handle;

my($port) = @ARGV;

$| = 1;

sub restart {
    my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
    printf "%4d.%d.%d %02d:%02d:%02d RESTART!\n", $year+1900, $mon+1, $mday, $hour, $min, $sec;
    system("sudo systemctl restart sshd");
    my $t; $t = AE::timer 10, 0, sub { undef $t;
        check();
    };
}

sub check {
    my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
    printf "%4d.%d.%d %02d:%02d:%02d checking...\n", $year+1900, $mon+1, $mday, $hour, $min, $sec;
    my $hd; $hd = AnyEvent::Handle->new(
        connect => ['127.0.0.1', $port],
        on_connect => sub {
            my(undef, $host, $port) = @_;
            print "  connected to $host:$port\n\e[K\e[B\e[K\e[A";
        },
    );
    my $good = 0;
    $hd->push_read(line => sub {
        my(undef, $line) = @_;
        say "  got $line";
        if( $line =~ /^SSH-/ ){
            print "  GOOD.\n\e[4A";
            $good = 1;
        } else {
            restart();
        }
        undef $hd;
    });

    my $t; $t = AE::timer 10, 0, sub { undef $t;
        if( $good ) {
            check();
        } else {
            say "  TIMEOUT!";
            undef $hd;
            restart();
        }
    };
}
check();

AE::cv->recv;
