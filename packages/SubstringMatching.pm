package SubstringMatching;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;


sub longest_common_substring{
    my ($str1, $str2) = @_;
    my @arr1 = split //, $str1;
    my @arr2 = split //, $str2;
    my $max = 0;
    my @lcs;
    for(my $i = 0; $i < scalar @arr1; $i++){
        for(my $j = 0; $j < scalar @arr2; $j++){
            if ($arr1[$i] eq $arr2[$j]){
                $lcs[$i][$j] ||= 0;
                $lcs[$i+1][$j+1] = $lcs[$i][$j] + 1;
                $max = $lcs[$i+1][$j+1] if $max < $lcs[$i+1][$j+1];
            }
        }
    }
    return $max;
}


# calculates levenshtein edit distance between two strings.
sub levenshtein {
    my ($str1, $str2) = @_;
    confess "String 1 is not defined" unless defined $str1;
    confess "String 2 is not defined" unless defined $str2;
    my @ar1 = split //, $str1;
    my @ar2 = split //, $str2;

    my $min = sub {
        my @inputs = @_;
        my $min = undef;
        foreach my $input (@inputs){
                if ((! defined $min) || $input < $min){
                        $min = $input;
                }
        }
        return $min;
    };


    my @dist;
    $dist[$_][0] = $_ foreach (0 .. @ar1);
    $dist[0][$_] = $_ foreach (0 .. @ar2);

    foreach my $i (1 .. @ar1){
        foreach my $j (1 .. @ar2){
            my $cost = $ar1[$i - 1] eq $ar2[$j - 1] ? 0 : 1;
            $dist[$i][$j] = $min->(
                        $dist[$i - 1][$j] + 1,
                        $dist[$i][$j - 1] + 1,
                        $dist[$i - 1][$j - 1] + $cost );
        }
    }
    return $dist[@ar1][@ar2];
}

1;
