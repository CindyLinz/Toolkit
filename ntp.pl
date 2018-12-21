#!/usr/bin/env perl

use strict;
use warnings;

use LWP::UserAgent;

if( !$ARGV[0] ) {
    my $ua = LWP::UserAgent->new;
    my($list) = $ua->get('https://www.pool.ntp.org/zone/tw')->content =~ m!<pre>(.*)</pre>!s;
    my @server = $list =~ /server (\S+)/g;
    if( !@server ) {
        print "no server found.\n";
        exit;
    }
    $ARGV[0] = $server[rand @server];
}

exec("sudo $0 @ARGV") || die $! if( $> );
print "use server $ARGV[0]\n";
system("ntpdate $ARGV[0]");
