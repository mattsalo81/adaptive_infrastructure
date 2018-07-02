package EffectiveRouting::Generate;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Switch;

our $delineator = "_";
our $undef_val = "undef";
our $undef_tech_e = "No way to generate an effective routing for";

# takes 
sub make_from_sms_hash{
    my ($record) = @_;
    my $tech = get($record, "TECHNOLOGY");
    my $area = get($record, "AREA");
    my $effective_routing;
    switch($tech){
        case 'LBC5'     {$effective_routing = LBC5($record);}
        case 'LBC7'     {$effective_routing = LBC7($record);}
        case 'LBC8'     {$effective_routing = LBC8($record);}
        case 'LBC8LV'   {$effective_routing = LBC8LV($record);}
        case 'HPA07'    {$effective_routing = HPA07($record);}
        case 'F05'      {$effective_routing = F05($record);}
        else {confess "$undef_tech_e <$tech>, please update <EffectiveRouting::Generate>";}
    }
    $effective_routing = join($delineator, ($tech, $area, $effective_routing));
    return $effective_routing;
}

# code 0 -> Test Area
# code 1 -> # of ML
# code 2 -> defined by naming convention
sub LBC5{
    my ($record) = @_;
    my $device = get($record, "DEVICE");
    my $routing = get($record, "ROUTING");
    my $num_ml = substr($routing, 5, 1);
    my $main_code;
    if ($device =~ m/^M06/){
        $main_code = substr($routing, 6, 2);
        if ($num_ml !~ m/^[0-4]$/ || $main_code eq ""){
            confess "Unexpected LBC5X routing format <$routing>";
        }
    }else{
        # don't trust the code for LBC5...
        $main_code = undef;
        if ($num_ml !~ m/^[0-4]$/){
            confess "Unexpected LBC5 routing format <$routing>";
        }
    }
    return make_routing_from_array($num_ml, $main_code);
}

# code 0 -> Test Area
# code 1 -> # of ML
# code 2 -> 2 char options
sub LBC7{
    my ($record) = @_;
    my ($main_code, $num_ml);
    my $routing = get($record, "ROUTING");
    my $prod_grp = get($record, "PROD_GRP");
    my $device = get($record, "DEVICE");
    if ($routing =~ m/(DCU|FVDCA)/){
        $main_code = substr($device, 4, 2);
        if ($prod_grp =~ m/\-([SDTQP67]LM)/){
            my $xlm = $1;
            $num_ml = 1 if ($xlm =~ /SLM/);
            $num_ml = 2 if ($xlm =~ /DLM/);
            $num_ml = 3 if ($xlm =~ /TLM/);
            $num_ml = 4 if ($xlm =~ /QLM/);
            $num_ml = 5 if ($xlm =~ /PLM/);
            $num_ml = 6 if ($xlm =~ /6LM/);
            $num_ml = 7 if ($xlm =~ /7LM/);
            unless (defined $num_ml){
                confess "Unable to get number of metal levels from " . Dumper $record;
            }
        }
    }elsif($routing =~ m/^.....([0-9])(..)/){
        ($main_code, $num_ml) = ($2, $1);
    }else{
        confess "Unexpected LBC7 routing format <$routing>";
    }
    return make_routing_from_array($num_ml, $main_code);
}

# code 0 -> Test Area
# code 1 -> # of ML
# code 2 -> 3 char
# code 3 -> optional char 4
sub LBC8{
    my ($record) = @_;
    my ($three_char, $char_4, $num_ml);
    my $device = get($record, "DEVICE");
    my $prod_grp = get($record, "PROD_GRP");
    my $routing = get($record, "ROUTING");
    if ($routing =~ m/DCU/){
        $three_char = substr($device, 4, 3);
        $char_4 = substr($device, 7, 1);
        if ($prod_grp =~ m/\-([SDTQP67]LM)/){
            my $xlm = $1;
            $num_ml = 1;
            $num_ml = 2 if ($xlm =~ /DLM/);
            $num_ml = 3 if ($xlm =~ /TLM/);
            $num_ml = 4 if ($xlm =~ /QLM/);
            $num_ml = 5 if ($xlm =~ /PLM/);
            $num_ml = 6 if ($xlm =~ /6LM/);
            $num_ml = 7 if ($xlm =~ /7LM/);
        }else{
            confess("Unable to get number of metal levels for effective routing from " . Dumper($record) . "\n");
        }
    }elsif($routing =~ m/^.....([0-9])(...)(.?)$/){
        # 9/10 character routings
        ($num_ml, $three_char, $char_4) = ($1, $2, $3);
    }else{
        confess "Unexpected LBC8 Routing format <$routing>";
    }

    $char_4 = "NONE" if $char_4 eq "" or not defined $char_4;
    return make_routing_from_array($num_ml, $three_char, $char_4);
}


# code 0 -> Test Area
# code 1 -> # of ML
# code 2 -> char 1
# code 3 -> char 2
# code 4 -> char 3
# code 5 -> char 4
sub LBC8LV{
    my ($record) = @_;
    my ($num_ml, $char_1, $char_2, $char_3, $char_4);
    my $routing = get($record, "ROUTING");
    if ($routing =~ m/^.....([0-9])(.)(.)(.)(.)$/){
        # M180VXISO4
        ($num_ml, $char_1, $char_2, $char_3, $char_4) = ($1, $2, $3, $4, $5);
    }else{
        confess "Unexpected LBC8LV Routing format <$routing>";
    }
    return make_routing_from_array($num_ml, $char_1, $char_2, $char_3, $char_4);
}

# code 0 -> Test Area
# code 1 -> # of ML
sub F05{
    my ($record) = @_;
    my $num_ml;
    my $strategy = get($record, "FE_STRATEGY");
    if($strategy =~ m/X(\d)L/){
        $num_ml = $1;
    }else{
        confess "Unexpected FE_STRATEGY <$strategy>, could not get num ml for F05";
    }
    return make_routing_from_array($num_ml);
}


# code 0 -> Test Area
# code 1 -> # of ML
# code 2 -> main naming convention
# code 3 -> flavor of hpa07
sub HPA07{
    # can't get iso from flavor code.  Could get it from the num ml
    my ($record) = @_;
    my $routing = get($record, "ROUTING");
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
    return make_routing_from_array($num_ml, $main_code, $flavor_code, $isoj);
}

sub get{
    my ($hash_ref, $key) = @_;
    my $value = $hash_ref->{$key};
    unless (defined $value){
        confess "Missing value for <$key> necessary to generate effective routing";
    }
    return $value;
}

sub make_routing_from_array{
    my @cleancodes = map {defined $_ ? $_ : $undef_val} @_;
    if (scalar @cleancodes == 0){
        confess "No codes provided to make effective routing!";
    }
    my $routing = join($delineator, @cleancodes);
    return $routing;
}

1;
