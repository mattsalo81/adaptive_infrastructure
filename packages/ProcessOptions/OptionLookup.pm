package OptionLookup;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;

my %effective_routing_to_option;
my $options_for_effective_routing_sth;
my $undef_error_msg = "No options defined for";

sub does_effective_routing_have_option{
    my ($technology, $effective_routing, $process_option) = @_;
    my $options = get_options_for_effective_routing($technology, $effective_routing);
    $process_option =~ tr/a-z/A-Z/;
    return defined $options->{$process_option};
}

# returns hashref where keys are options -> static
sub get_options_for_effective_routing{
    my ($technology, $effective_routing) = @_;
    my %options;
    unless(defined $effective_routing_to_option{$effective_routing}){
        # get query
        my $sth = get_options_for_effective_routing_sth();
        Logging::diag("Pulling Process Options for $effective_routing on $technology");
        unless($sth->execute($technology, $effective_routing)){
            confess "Could not execute options_for_effective_routing_sth";
        }
        # pull results
        my $records = $sth->fetchall_arrayref();
        # put results into hash
        my @options = map {my $option = $_->[0]; $option =~ tr/a-z/A-Z/; $option} @{$records};
        # make options all uppercase
        @options{@options} = @options;
        $effective_routing_to_option{$effective_routing} = \%options;
    }
    if (scalar keys %{$effective_routing_to_option{$effective_routing}} == 0){
        confess "$undef_error_msg technology <$technology> and effective routing <$effective_routing>";
    }
    return $effective_routing_to_option{$effective_routing};
}

sub get_options_for_effective_routing_sth{
    unless (defined $options_for_effective_routing_sth){
        my $conn = Connect::read_only_connection("etest");
        my $sql = q{
            select 
                process_option 
            from 
                effective_routing_to_options 
            where 
                technology = ?
                and effective_routing = ?
        };
        $options_for_effective_routing_sth = $conn->prepare($sql);
    }
    unless (defined $options_for_effective_routing_sth){
        confess "Could not get options_for_effective_routing_sth";
    }
    return $options_for_effective_routing_sth;
}

sub are_options_available_for_effective_routing{
    my ($tech, $effective_routing) = @_;
    my $success = 1;
    eval{
        get_options_for_effective_routing($tech, $effective_routing);
        1;
    } or do {
        $success = 0;
    };
    return $success;
}

1;
