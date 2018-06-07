package Spec;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;

sub new{
    my ($class) = @_;
    my $text = "";
    my $self = \$text;
    return bless $self, $class
}

sub add_horizontal_rule{
    my ($self) = @_;
    $self->comment("=" x 58);
}

sub comment{
    my ($self, $text) = @_;
    my @lines = split("\n", $text);
    foreach my $line (@lines){
        $$self .= "# $line\n";
    }
}

sub add_comment_entry{
    my ($self, $entry) = @_;
    my @new_entry = @{$entry};
    $new_entry[0] = "# " . $new_entry[0];
    $self->add_entry(\@new_entry);
}

sub add_entry{
    my ($self, $entry) = @_;
    $$self .= sprintf("%-21s   %d   %-10G   %-10G   %d   %-2d\n", @{$entry});    
}

sub get_text{
    my ($self) = @_;
    return $$self;
}

1;
