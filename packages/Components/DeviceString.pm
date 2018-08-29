package DeviceString;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Components::Bits;

Logging::set_level(0);

my @char_lookup = qw(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9 + /);
my $max_char = 150;
my $bits_per_char = 6;
my $max_bits = $max_char * $bits_per_char;
unless(scalar @char_lookup == 2**$bits_per_char){
    confess "Somebody broke the device string config";
}

sub get_device_string{
    my ($technology, $program) = @_;
    my $string;
    eval{
        my $bits = Bits::get_bits_for_program($technology, $program);
        $string = convert_bits_to_device_string($bits);
        1;
    } or do {
        my $e = $@;
        if ($e =~ m/$Bits::not_associated_error<[^>]*>/){
            die "The Following components are not associated to a bit in $technology, : $1";
        }elsif ($e =~ m/$Bits::no_comp_error/){
            Logging::debug("$technology program $program does not have any component information available");
        }else{  
            confess "Could not get device string because : $e";
        }
        $string = $char_lookup[-1] x $max_char;
    };
    return $string;
}

sub convert_bits_to_device_string{
    my ($bits) = @_;

    my @bitstring = (0) x $max_bits;
    foreach my $bit (@{$bits}){
        $bitstring[$bit-1] = 1;
    }

    Logging::diag("Bitstring is " . join("", @bitstring));
    if (scalar @bitstring > $max_bits){
        confess "Way too many bits to handle";
    }
    
    my $string = "";

    for(my $i = 0; $i < $max_bits; $i += $bits_per_char){
        my $value = oct("0b" . join("", @bitstring[$i..($i + $bits_per_char - 1)]));
        my $char = val2char($value);
        $string .= $char;
    }
    
    # shorten length
    $string =~ s/A+$/A/;    

    Logging::diag("Device String is $string");
    return $string;
}

sub val2char{
    my ($value) = @_;
    my $char = $char_lookup[$value];
    if ($value < 0 || not defined $char){
        confess "Tried to convert an invalid value to character ($value)";
    }
    return $char;
}

1;
