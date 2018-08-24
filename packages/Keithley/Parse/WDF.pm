package Parse::WDF;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;

my $eoh = '<EOH>';
my $eosites = '<EOSITES>';
my $eosubsites = '<EOSUBSITES>';
my $dummy_coord = 0.005;

sub new{
    my ($class, $text) = @_;
    my $self = {
        TEXT            => $text,
        header          => [],
        # subsite stuff
        alignment_module=> undef,
        modules         => {}, # 'my_subsite' -> [x_coord, y_coord]
        dummy_modules   => {}, # 'dummy_sub' -> some_defined_val
        # site stuff
        orig_patterns   => {}, # 'LBC5_9site' -> { 1 => [x1, y1]}
        sites           => {}, # {1 -> [x1, y1]}
        patterns        => {},
    };
    bless $self, $class;
    $self->parse();
    return $self;
} 

sub get_new_text{
    my ($self) = @_;
    my $text = join("\n", @{$self->{'header'}});
    $text .= "\n";
    # unpack the patterns
    foreach my $pattern (@{$self->get_pattern_order()}){
        $text .= "Pattern,$pattern\n";        
        foreach my $site (sort keys %{$self->{"patterns"}->{$pattern}}){
            my ($x, $y) = @{$self->{"patterns"}->{$pattern}->{$site}};
            $text .= "$site,$x,$y\n";
        }
    }
    $text .= "$eosites\n";
    $text .= "Site,Single,Single\n";
    # unpack the subsites
    my $a_mod = $self->get_alignment_mod();
    # alignment module
    $text .= "$a_mod,0,0\n";
    # alphabetical standard modules
    foreach my $mod (sort keys %{$self->{"modules"}}){
        my ($x, $y) = @{$self->{"modules"}->{$mod}};
        $text .= "$mod,$x,$y\n";
    }
    # dummy
    foreach my $dummy (sort keys %{$self->{"dummy_modules"}}){
        $text .= "$dummy,$dummy_coord,$dummy_coord\n";
    }
    $text .= "$eosubsites";
    return $text;
}

# order by lowest site number used
sub get_pattern_order{
    my ($self) = @_;
    my $patterns = $self->{"patterns"};
    my %pattern_min_site;
    foreach my $pattern (keys %{$patterns}){
        my $min;
        # get lowest site number for this pattern
        foreach my $site (keys %{$patterns->{$pattern}}){
            if ((not defined $min) || $site < $min){
                $min = $site;
            }
        }
        confess "Found pattern with no sites!" unless defined $min;
        $pattern_min_site{$pattern} = $min;
    }
    my @sorted = sort {$pattern_min_site{$a} <=> $pattern_min_site{$b}} keys %pattern_min_site;
    return \@sorted;
}

sub parse{
    my ($self) = @_;
    my @lines = split(/\n/, $self->{"TEXT"});
    # remove leading/trailing whitespace and delete blank lines
    @lines = map {s/^\s*//; $_} @lines;
    @lines = map {s/\s*$//; $_} @lines;
    @lines = grep {m/\S/} @lines;
    my $location = "header";
    my $pattern;
    foreach my $line (@lines){
        if($location eq "header"){      # PARSE HEADER
            push @{$self->{"header"}}, $line;
            $location = "sites" if ($line eq $eoh);
        }elsif($location eq "sites"){   # PARSE SITES
            # update pattern
            if($line =~ m/^Pattern,(\S*)$/){
                $pattern = $1;
            }elsif($line =~ m/^([0-9]+),([0-9]+),([0-9]+)$/){
                confess "Undefined pattern at <$line>" unless defined $pattern;
                $self->add_shot($pattern, $1, $2, $3);
            }elsif($line eq $eosites){
                $location = "subsites";
            }else{
                confess "Unexpecte WDF line format <$line>";
            }
        }elsif($location eq "subsites"){# PARSE SUBSITES
            if($line =~ m/^site,/i){
                # do nothing
            }elsif($line =~ m/^[a-z0-9][a-z0-9_]*,[^,]+,[^,]+$/i){
                my ($mod, $x, $y) = split(/,/, $line);
                $self->add_mod($mod, $x, $y);
            }elsif($line eq $eosubsites){
                $location = "done";
            }
        }elsif($location eq "done"){    # HOLD
            # do nothing
        }else{
            confess "Unexpected parser state <$location> in <$line>";
        }
    }
    confess "Parser did not complete correctly! ended in state <$location>" unless $location eq "done";
    $self->{"patterns"} = $self->{"orig_patterns"}; 
}

sub add_mod{
    my ($self, $mod, $x, $y) = @_;
    if (is_alignment($x, $y)){
        $self->{"alignment_module"} = $mod;
    }elsif (is_dummy($x, $y)){
        $self->add_dummy($mod);   
    }else{
        $self->{"modules"}->{$mod} = [$x, $y];
    }
}

sub get_alignment_mod{
    my ($self) = @_;
    my $a_mod = $self->{"alignment_module"};
    confess "No alignment module found" unless defined $a_mod;
    return $a_mod
}

sub get_real_modules{
    my ($self) = @_;
    my @mods = ($self->get_alignment_mod());
    push @mods, keys %{$self->{"modules"}};
    return \@mods;
}

sub add_dummy{
    my ($self, $mod) = @_;
    $self->{"dummy_modules"}->{$mod} = 1;
}

sub is_dummy{
    my ($x, $y) = @_;
    return (($x == $dummy_coord) && ($y == $dummy_coord));
}

sub is_alignment{
    my ($x, $y) = @_;
    return (($x == 0) && ($y == 0));
}

sub add_shot{
    my ($self, $pattern, $site, $x, $y) = @_;
    $self->{"orig_patterns"}->{$pattern}->{$site} = [$x, $y];
    my $orig = $self->{"sites"}->{$site};
    if(defined $orig){
        my ($ox, $oy) = ($orig->[0], $orig->[1]);
        if (($ox != $x) || ($oy != $y)){
            confess "Site <$site> has conflicting coordinates, originally [$ox, $oy], found [$x, $y]";
        }
    }
    $self->{"sites"}->{$site} = [$x, $y];    
}

1;
