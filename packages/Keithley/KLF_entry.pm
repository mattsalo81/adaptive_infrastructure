package KLF_entry;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;

# manages/creates interface for high level KLF generation
# does not use legacy/old adaptive KLF convention of MODULExPARM
# not needed by automation

my $inf = '9e+99';

sub new{
    my ($class, $parameter) = @_;
    confess "Parameter name not provided" unless defined $parameter;
    my $self = {
        ID      => $parameter,
        NAM     => $parameter,
        CAT     => 't0',
        AF      => 0,
        AL      => 0,
        VALl    => "-$inf",
        VALh    => "$inf",
        SPCl    => "-$inf",
        SPCh    => "$inf",
        CNTl    => "-$inf",
        CNTh    => "$inf",
        ENGl    => "-$inf",
        ENGh    => "$inf",
        ena     => 1,
        usr1    => 'N',
        usr2    => undef,
        cla     => undef,
    };
    bless $self, $class;
    return $self;
}

# returns the text of limit entry for the klf
sub get_text{
    my ($self) = @_;
    my $text = "";
    foreach my $field (qw(ID NAM CAT AF AL)){
        $text .= "$field," . $self->{$field} . "\n" if defined $self->{$field};
    }
    foreach my $limit (qw(VAL SPC CNT ENG)){
        $text .= "$limit," . $self->{$limit . "l"} . "," . $self->{$limit . "h"} . "\n";
    }
    foreach my $field (qw(ena usr1 usr2 cla)){
        $text .= "$field," . $self->{$field} . "\n" if defined $self->{$field};
    }
    $text .= "<EOL>\n";
    return $text;
}

# turns on immediate mapping
sub enable_mapping{
    my ($self) = @_;
    confess "Cannot set a non-9 site parameter to immediate mapping" unless $self->{'cla'} eq "MAPNRPT";
    $self->{"cla"} = "MAP";
}

# sets the component bit association
sub set_bit{
    my ($self, $bit) = @_;
    $self->{"usr2"} = $bit;
}

sub get_bit{
    my ($self) = @_;
    return $self->{"usr2"};
}

# enables/disables on true/false values
sub set_test{
    my ($self, $val) = @_;
    if ($val){
        $self->{'usr1'} = undef;
    }else{
        $self->{'usr1'} = 'N';
    }
}

sub is_enabled{
    my ($self) = @_;
    return !(defined $self->{"usr1"} and $self->{"usr1"} eq "N");
}

# sets the number of sites to test
# 0 -> off
# 1 -> random monitor
# 5 -> WASNRPT
# 9 -> MAPNRPT
sub set_num_sites{
    my ($self, $num) = @_;
    confess "number of sites not defined" unless defined $num;
    if($num == 1){
        $self->{"cla"} = undef;
    }elsif ($num == 5){
        $self->{"cla"} = 'WASNRPT';
    }elsif ($num == 9){
        $self->{"cla"} = 'MAPNRPT';
    }elsif ($num == 0){
        $self->set_test(0);
    }else{
        confess "Could not set num sites to $num";
    }
}

sub get_num_sites{
    my ($self) = @_;
    return 0 unless $self->is_enabled();
    return 1 unless defined $self->{"cla"};
    return 5 if $self->{"cla"} eq "WASNRPT";
    return 9 if $self->{"cla"} =~ m/^MAP/;
}


# returns the name of the limit based on the info given.
sub get_limit_type{
    my ($type) = @_;
    my $lim;
    if ($type =~ m/^v(al(id)?)?/i){
        $lim = 'VAL';
    }elsif($type =~ m/^s(pc|pec)?/i){
        $lim = 'SPC';
    }elsif($type =~ m/^c(nt|ontrol)?/i){
        $lim = 'CNT';
    }elsif($type =~ m/^e(ng(ineering)?)?/i){
        $lim = 'ENG';
    }else{
        confess "unexpected limit type $type";
    }
    return $lim;
}

# sets the upper/lower limit for the provided type
sub set_limits{
    my ($self, $type, $ll, $ul) = @_;
    $ll = "-$inf" unless defined $ll;
    $ul = "$inf" unless defined $ul;
    my $lim = get_limit_type($type);
    $self->{$lim . "l"} = $ll;
    $self->{$lim . "h"} = $ul;
}

sub get_limits{
    my ($self, $type) = @_;
    my $lim = get_limit_type($type);
    return ($self->{$lim . "l"}, $self->{$lim . "h"});
}



# toggles the parameter for the MS's screen
# takes true/false
sub set_reporting_on_ms_screen{
    my ($self, $val) = @_;
    if($val){
        $self->{'CAT'} = 't1';
    }else{
        $self->{'CAT'} = 't0';
    }
}

sub is_reporting_on_ms_screen{
    my ($self) = @_;
    return $self->{'CAT'} =~ m/1/;
}

1;
