#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Std;
use Cwd qw(abs_path);

my %opt;
getopts('A:B:', \%opt);
$opt{A} //= 0;
$opt{B} //= 0;

my($pattern, @root) = @ARGV;
$root[0] //= '.';

my %touched_inode;

sub check_git {
    my $path = abs_path($_[0]);
    {
        #print "check_git($path)\n";
        return 1 if( -d "$path/.git" );
        if( $path =~ m![^/]! ) {
            $path =~ s!(.*)/.+!$1!;
            redo;
        } else {
            return 0;
        }
    }
}

sub grep_entry {
    my($root) = @_;
    chomp $root;
    #print "grep_entry $root\n";
    my $inode_num = (stat $root)[1];
    return if( exists $touched_inode{$inode_num} );
    $touched_inode{$inode_num} = 1;

    if( -l $root ) {
        #print "symlink $root\n";
        #print readlink($root),$/;
        eval {
            my $link = readlink $root;
            if( substr($link, 0, 1) eq '/' ) {
                grep_entry($link);
            } else {
                grep_entry($root =~ s!(.*/|^).*!$1!r . $link);
            }
        };
        if( $@ ) {
            warn $@;
        }
    } elsif( -d $root ) {
        if( check_git($root) ) {
            my $target_f;
            if( open $target_f, "git ls-files -- $root|" ) {
                while( my $target = <$target_f> ) {
                    grep_entry($target);
                }
                close $target_f;
            }
        } else {
            my $dir;
            if( opendir $dir, $root ) {
                while( my $entry = readdir $dir ) {
                    next if( $entry eq '.' || $entry eq '..' );
                    grep_entry("$root/$entry");
                }
                close $dir;
            }
        }
    } else {
        #warn "grep file $root";
        my $f;
        if( open $f, $root ) {
            my @before;
            my $last_match = -$opt{A};
            while( my $line = <$f> ) {
                if( $line =~ /$pattern/ ) {
                    while( my $before = shift @before ) {
                        print $root, '-', $. - @before - 1, '-', $before;
                    }
                    print "$root:$.:$line";
                    $last_match = $.;
                } elsif( $. - $last_match <= $opt{A} ) {
                    print "$root-$.-$line";
                } else {
                    push @before, $line;
                    shift @before if @before > $opt{B};
                }
            }
            close $f;
        }
    }
}

#print "pattern=$pattern\n";

for my $root (@root) {
    #print "root=$root\n";
    grep_entry($root);
}
