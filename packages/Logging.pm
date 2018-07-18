package Logging;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages/';
use Carp;
use Data::Dumper;

# general puprose logging package.
# allows four levels of logging (silent, event, debug, and diag)
# allows error messages
# by default, all log messages get printed to stdout and all error messages get printed to stderr
# but these could all be easily redirected to an email or a file by setting the file handle


my $log = *STDOUT;
my $err = *STDERR;

# logging level...
my $level = 1;
my %log_levels = (
    SILENT	=> 0,
    EVENT	=> 1,
    DEBUG	=> 2,
    DIAG	=> 3,
);

sub set_level{
    my ($value) = @_;
    $value =~ tr/a-z/A-Z/;
    if (defined $log_levels{$value}){
        $level = $log_levels{$value};
    }elsif ($level == 0 || $level == 1 || $level == 2 || $level == 3){
        $level = $value;
    }else{
        confess("Could not set log_level to <$value>\n");
    }
    event("log level set to $level");
}

sub set_log{
    ($log) = @_;
}

sub event{
    my ($text) = @_;
    if($level >= $log_levels{"EVENT"}){
        my ($package, $filename, $line) = caller;
        print_log("$package : " . $text);
    }
}

sub debug{
    my ($text) = @_;
    if($level >= $log_levels{"DEBUG"}){
        my ($package, $filename, $line) = caller;
        print_log("$package : " . $text);
    }
}

sub diag{
    my ($text) = @_;
    if($level >= $log_levels{"DIAG"}){
        my ($package, $filename, $line) = caller;
        print_log("$package : " . $text);
    }
}

sub print_log{
    my ($text) = @_;
    $text .= "\n" unless $text =~ m/\n$/;
    my ($sec, $min, $hour, @garbage) = localtime(time);
    my $timestamp = sprintf("%02d:%02d:%02d", $hour, $min, $sec);
    print $log ("$timestamp : $text");
}

sub set_err{
    ($err) = @_;
}

sub error{
    my ($text) = @_;
    $text .= "\n" unless $text =~ m/\n/;
    print $err ($text);
}


