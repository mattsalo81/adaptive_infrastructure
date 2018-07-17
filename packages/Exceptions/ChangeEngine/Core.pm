package Exceptions::ChangeEngine::Core;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;
use SMS::SMSDigest;
use Exceptions::GetExceptions;
use Exceptions::ChangeEngine::Limits;

my $exception_source_sth;



sub run{
    # create transaction/sms tables
    Logging::event("Initializing Change Engine");
    my $trans = Connect::new_transaction("etest");
    my $sms_master = SMSDigest::get_all_active_records();
    eval{
        # get all exception numbers
        my $exceptions = GetExceptions::get_all_exception_numbers();
        foreach my $exception_number (@{$exceptions}){
            run_exception($trans, $exception_number, $sms_master);
        }
        1;
    } or do {
        my $e = $@;
        $trans->rollback();
        confess "Change Engine aborted without any modifications because : $e";
    };
    Logging::event("Change Engine Complete");
}

sub run_exception{
    my ($trans, $exception_number, $sms_master) = @_;
    my $dev_lpt_opn_list = GetExceptions::for_exception_number($exception_number);
    Logging::event("Implementing Changes for Exception $exception_number");
    eval{
        Exceptions::ChangeEngine::Limits::process_exceptions($trans, $sms_master, $exception_number, $dev_lpt_opn_list);
        $trans->commit();
    } or do {
        my $e = $@;
        $trans->rollback();
        warn "Change Engine skipped exception $exception_number because : $e";    
    };
}

sub get_exception_source{
my ($exception_number) = @_;
my $sth = get_exception_source_sth();
$sth->execute($exception_number);
my $rec = $sth->fetchrow_arrayref();
my $source = $rec->[0];
return $source;
}

sub get_exception_source_sth{
unless (defined $exception_source_sth){
    my $conn = Connect::read_only_connection("etest");
    my $sql = q{
        select source from exception_sources where
        exception_number = ?
    };
    $exception_source_sth = $conn->prepare($sql);
}
unless (defined $exception_source_sth){
    confess "could not prepare exception_source_sth";
}
return $exception_source_sth;
}



1;
