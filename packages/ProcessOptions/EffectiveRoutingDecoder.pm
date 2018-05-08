package EffectiveRoutingDecoder;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use ProcessOptions::ProcessDecoder;
use Switch;

# this package contains all the logic for taking an effective routing (generated earlier) and breaking it down into the process codes
# then using the codes to determine the process options through the ProcessDecoder.
# it allows easy transition from effective routing -> process options

sub get_options_for_effective_routing{
    my ($technology, $effective_routing) = @_;
    my $codes = get_codes_from_routing($technology, $effective_routing);
    return ProcessDecoder::get_options_for_code_array($technology, $codes);
}

# returns an array of codes
# $return->[0] is assumed to be code_type 0
# undef is okay to return, if no codes are found for that index
sub get_codes_from_routing{
    my ($technology, $routing) = @_;
    my $codes = [];
    switch($technology){
        case 'TEST' {$codes->[0] = substr($routing, 4, 6)} # used for testing get_codes_from_routing
        case 'F05' {$codes = F05_get_codes_from_routing($routing)}
        case 'HPA07' {$codes = HPA07_get_codes_from_routing($routing)}
        case 'LBC5' {$codes = LBC5_get_codes_from_routing($routing)}
        case 'LBC7' {$codes = LBC7_get_codes_from_routing($routing)}
        case 'LBC8' {$codes = LBC8_get_codes_from_routing($routing)}
        case 'LBC8LV' {$codes = LBC8LV_get_codes_from_routing($routing)}
        else {die "No defined way to parse routings for technology <$technology>, need to edit <get_codes_from_routing>\n";}
    }
    return $codes;
}

# code 0 -> Test Area
# code 1 -> # of ML
# code 2 -> defined by nameing convention
sub LBC5_get_codes_from_routing{
    my ($routing) = @_;
    my $area;
    ($area, $routing) = strip_test_area($routing);
    my $num_ml = substr($routing, 5, 1);
    my $main_code;
    if ($routing =~ m/-X$/){
        $main_code = substr($routing, 6, 2);
        if ($num_ml !~ m/^[0-4]$/ || $main_code eq ""){
            confess "Unexpected LBC5X routing format <$routing>";
        }
    }else{
        # don't trust the code for LBC5...
        $main_code = undef;
    }
    return [$area, $num_ml, $main_code];
}

# code 0 -> Test Area
# code 1 -> # of ML
# code 2 -> main naming convention
# code 3 -> flavor of hpa07
sub HPA07_get_codes_from_routing{
    # can't get iso from flavor code.  Could get it from the num ml
    my ($routing) = @_;
    my $area;
    ($area, $routing) = strip_test_area($routing);
    if ($routing eq "M102W3"){
        $routing = "M102W3++";
    }
    my $main_code;
    if(length($routing) > 8 && substr($routing,6,1) eq "V"){
        # class v routings push the device code back
        $main_code = substr($routing, 7, 2);
    }else{
        $main_code = substr($routing, 6, 2);
    }
    my $isoj;
    if (substr($routing,4,1) eq "J") {
        $isoj = "J";
    }else{
        $isoj = "NOTJ";
    }
    my $num_ml = substr($routing, 5, 1);
    my $flavor_code = substr($routing, 1, 3);
    if ($num_ml !~ m/^[0-7]$/ || $main_code eq "" || $flavor_code !~ m/^10[0237]$/){
        confess "Unexpected HPA07 routing format <$routing>";
    }
    return [$area, $num_ml, $main_code, $flavor_code, $isoj];
}

# code 0 -> Test Area
# code 1 -> # of ML
# code 2 -> 3 char
# code 3 -> optional char 4
sub LBC8_get_codes_from_routing{
    my ($routing) = @_;
    my ($area, $three_char, $char_4, $num_ml);
    ($area, $routing) = strip_test_area($routing);
    if ($routing =~ m/DCU-(...)(.?)-([0-9])$/){
        # DCU routing
        ($three_char, $char_4, $num_ml) = ($1, $2, $3);
    }elsif($routing =~ m/^.....([0-9])(...)(.?)$/){
        # 9/10 character routings
        ($num_ml, $three_char, $char_4) = ($1, $2, $3);
    }else{
        confess "Unexpected LBC8 Routing format <$routing>";
    }
    $char_4 = "NONE" if $char_4 eq "";
    return [$area, $num_ml, $three_char, $char_4];
}

# code 0 -> Test Area
# code 1 -> # of ML
# code 2 -> 2 char options
sub LBC7_get_codes_from_routing{
        my ($routing) = @_;
        my ($area, $main_code, $num_ml);
    ($area, $routing) = strip_test_area($routing);
    if ($routing =~ m/(DCU.?|FVDCA)-(..)-(.)$/){
                # DCU routing
        ($main_code, $num_ml) = ($2, $3);
        }elsif($routing =~ m/^.....([0-9])(..)/){
        # std routing format        
        ($main_code, $num_ml) = ($2, $1);
    }else{
                confess "Unexpected LBC7 Routing format <$routing>";
        }
        return [$area, $num_ml, $main_code];
}

# code 0 -> Test Area
# code 1 -> # of ML
sub F05_get_codes_from_routing{
    my ($routing) = @_;
    my ($area, $num_ml);
    ($area, $routing) = strip_test_area($routing);
    if ($routing =~ m/-([0-9])$/){
        $num_ml = $1;
    }else{
        confess "Unexpected F05 Routing format <$routing>";
    }
    return [$area, $num_ml];
}

# code 0 -> Test Area
# code 1 -> # of ML
# code 2 -> char 1
# code 3 -> char 2
# code 4 -> char 3
# code 5 -> char 4
sub LBC8LV_get_codes_from_routing{
    my ($routing) = @_;
    my ($area, $num_ml, $char_1, $char_2, $char_3, $char_4);
    ($area, $routing) = strip_test_area($routing);
    if ($routing =~ m/^.....([0-9])(.)(.)(.)(.)$/){
        # M180VXISO4
        ($num_ml, $char_1, $char_2, $char_3, $char_4) = ($1, $2, $3, $4, $5);
    }else{
        confess "Unexpected LBC8LV Routing format <$routing>";
    }
    return [$area, $num_ml, $char_1, $char_2, $char_3, $char_4];
}

sub strip_test_area{
    my ($routing) = @_;
    my $area;
    if ($routing =~ m/___/ || $routing =~ m/__.*__/){
        confess "Unexpected Routing format <$routing>";
    }
    if($routing =~ m/^(.*)__(.*)$/){
        $area = $1;
        $routing = $2;
    }else{
        confess "Could not extract test area from routing <$routing>";
    }
    return ($area, $routing);
}
1;
