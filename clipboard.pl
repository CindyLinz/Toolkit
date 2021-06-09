#!/usr/bin/env perl
use shit;
use feature qw(say);

if( @ARGV != 1 ) {
    say "usage: $0 [tmp_file_path]";
    exit 1;
}

my $tmp_file = $ARGV[0];

system("terminator -e 'vim $tmp_file'");

my $vim_pid;
FIND_EDITOR: while(!$vim_pid) {
    opendir my($proc_dir), '/proc';
    while( my $proc_id = readdir $proc_dir ) {
        next if( $proc_id !~ /^\d+$/ );
        open my($cmdline_f), "/proc/$proc_id/cmdline";
        local $/;
        if( <$cmdline_f> eq "vim\0$tmp_file\0" ) {
            $vim_pid = $proc_id;
            last FIND_EDITOR;
        }
    }
    select undef, undef, undef, .01;
}

while(kill 0, $vim_pid) {
    select undef, undef, undef, .01;
}

system("xclip -r -se c -i $tmp_file");
unlink $tmp_file;
