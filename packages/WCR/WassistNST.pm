package WCR::WassistNST;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use WCR::Associate;
use Database::Connect;

my $body_sth;

sub get_body_for_coordref{
    my ($coordref) = @_;
    my $wcf;
    eval{
        $wcf = WCR::Associate::get_wcf($coordref);
        1;
    } or do{
        my $e = $@;
        if ($e =~ m/$WCR::Associate::no_wcf_e/){
            # none found
            Logging::diag("Could not find wcf for <$coordref>");
            return undef;
        }else{
            confess $e;
        }
    };
    confess "WCF is undefined, probably programmer's fault" unless defined $wcf;
    return (get_body_for_wcf($wcf), $wcf); 
    
}

# returns a scalar reference to the text of the body, or undef
sub get_body_for_wcf{
    my ($wcf) = @_;
    my $sth = get_body_sth();
    $sth->execute($wcf);
    my $row = $sth->fetchrow_arrayref();
    if (defined $row){
        my $body = $row->[0];
        if ($body ne ""){
            return \$body;
        }
        Logging::diag("Found empty wassist/nst file for wcf <$wcf>");
        return undef;
    }
    Logging::diag("Found no wassist/nst file for wcf <$wcf>");
    return undef;
}

sub get_body_sth{
    unless (defined $body_sth){
        my $conn = Connect::read_only_connection('wcrepo');
        my $sql = q{
            select 
                attachment_content 
            from wcrepo.wcf_attachment
                where WCF = ? 
                and attachment_sourcetype = 'WASSIST_NST'
        };
        $body_sth = $conn->prepare($sql, {ora_pers_lob=>1});
    }
    unless (defined $body_sth){
        confess "could not get body_sth";
    }
    return $body_sth;
}


1;
