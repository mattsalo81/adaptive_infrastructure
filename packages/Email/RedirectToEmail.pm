package RedirectToEmail;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Email::TiedStream;
use Logging;

my @emails = ('m-salo@ti.com');

print "Using RedirectToEmail.pm.  if anything on STDERR is read, STDOUT and STDERR will be sent to " . join(", ", @emails) . "\n";

*OLD_STDOUT = *STDOUT;
*OLD_STDERR = *STDERR;

tie *TIED_STDOUT, 'TiedStream', *OLD_STDOUT;
tie *TIED_STDERR, 'TiedStream', *OLD_STDERR;
*STDOUT = *TIED_STDOUT;
*STDERR = *TIED_STDERR;

Logging::set_log(*TIED_STDOUT);
Logging::set_err(*TIED_STDERR);

END{
    *STDOUT = *OLD_STDOUT;
    *STDERR = *OLD_STDERR;

    my $errors = <TIED_STDERR>;
    if ($errors ne ""){
        print "Something was printed to STDERR, emailing all logs...\n";
        my $subject = "$0 : Errors in log";
        my $body = "ERRORS ENCOUNTERED WHILE RUNNING $0\nARGUMENTS =  " . Dumper(\@ARGV) . "\n";
        $body .= "\n\nLOG START\n=============================================================================\n\n";
        $body .= $TiedStream::all_streams;
        $body .= "\n\n=============================================================================\nLOG END\n";
        my $email;
        open ($email, "| mail -s '$subject' " . join(" ", @emails)) or confess "Emails broken.  Dunno what to do with log";
        print $email $body;
        close $email;
    }else{
        print "Nothing printed to STDERR, not sending any emails\n";
    }
}

1;
