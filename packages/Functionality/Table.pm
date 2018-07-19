package Functionality::Table;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;
use Functionality::Record;
use Functionality::List;

my $populate_sth;

sub new{
    my ($class) = @_;
    my $self = [];
    bless $self, $class;
    $self->clear();
    return $self;
}

sub clear{
    my ($self) = @_;
    @{$self} = ();
}

sub add_record{
    my ($self, $rec) = @_;
    push @{$self}, $rec;
}

sub populate{
    my ($self, $technology, $coord_ref, $test_group) = @_;
    Logging::diag("Pulling down functionality table for coordref <$coord_ref>");
    $self->clear();
    my $sth = get_populate_sth();
    $sth->execute($technology, $coord_ref, $test_group);
    while (my $rec = $sth->fetchrow_hashref("NAME_uc")){
        my $c_rec = Functionality::Record->new($rec);
        $self->add_record($c_rec);
    }
}

sub process{
    my ($self, $effective_routing, $sms_routing) = @_;
    my $init_mods = $self->get_unique_modules();
    $self->remove_invald_lpt_po($effective_routing, $sms_routing);
    $self->resolve_precedence();
    my $post_mods = $self->get_unique_modules();
    # look for unresolved modules
    unless(scalar @{$init_mods} == scalar @{$post_mods}){
        my %mods;
        @mods{@{$init_mods}} = @{$init_mods};
        my @unresolved = grep {not defined $mods{$_}} @{$post_mods};
        confess "Some modules did not resolve : <" . join(">, <", @unresolved) . ">";
    }
}

sub evaluate_functionality{
    my ($self, $scope, $functionality) = @_;
    my $l = $self->get_functionality_list();
    return $l->evaluate_functionality($scope, $functionality);
}

sub get_functionality_list{
    my ($self) = @_;
    my $list = Functionality::List->new();
    foreach my $rec (@{$self}){
        my $functionality = $rec->get("FUNCTIONALITY");
        if ($functionality eq "SF"){
            $list->set_functional();
        }elsif($functionality eq "NSF"){
            $list->set_nonfunctional();
        }elsif($functionality =~ m/^SNF[0-9]$/i){
            my $priority = $rec->get("PRIORITY");
            $list->add_nonspec($functionality, $priority);
        }else{
            confess "Unrecognized functionality state <$functionality>";
        }
    }
    return $list;
}

sub get_populate_sth{
    unless (defined $populate_sth){
        my $conn = Connect::read_only_connection("etest");
        my $sql = q{
            select distinct
                s.technology,
                s.test_mod || '_' || s.mod_rev as scribe_module,
                tc.test_mod,
                tf.mod_rev as matched_rev,
                tf.test_group as matched_group,
                tf.priority,
                tf.functionality,
                tf.process_option,
                tf.logpoints
            from
                scribes s
                LEFT JOIN test_collectible tc
                    on  tc.technology = s.technology
                    and tc.test_mod = s.test_mod
                LEFT JOIN test_functional tf
                    on  tf.technology = tc.technology
                    and tf.test_mod = s.test_mod
                    and (tf.mod_rev = s.mod_rev or tf.mod_rev = '*')
                    and (tf.test_group = tc.test_group or tf.test_group = '*')
            where
                s.technology = ?
                and s.coordref = ?
                and (tc.test_group = ? or tc.test_group is null)
        };
        $populate_sth = $conn->prepare($sql);
    }   
    unless (defined $populate_sth){
        confess "Could not get populate_sth";
    }
    return $populate_sth;
}

sub get_unique_modules{
    my ($self) = @_;
    my %mods;
    foreach my $rec (@{$self}){
        $mods{$rec->get("SCRIBE_MODULE")} = "yep";
    }
    return [keys %mods];
}

sub remove_invalid_lpt_po{
    my ($self, $effective_routing, $sms_routing) = @_;
    @{$self} = grep {$_->satisfies_lpt_and_po($effective_routing, $sms_routing)} @{$self};
}

sub validate_modules_resolved{
    my ($self)= @_;
    foreach my $rec (@{$self}){
        unless (defined $rec->get("MODULE")){
            confess "Undefined Module " . $rec->get("SCRIBE_MODULE");
        }
    }
}

sub resolve_precedence{
    my ($self) = @_;
    Logging::diag("Resolving matching precedence");
    my %mod_instance_hash;
    # categorize records by modulexrev instace
    foreach my $rec (@{$self}){
        my $key = $rec->get("SCRIBE_MODULE");
        $mod_instance_hash{$key} = [] unless defined $mod_instance_hash{$key};
        push @{$mod_instance_hash{$key}}, $rec
    }
    $self->clear();
    # order records by what they matched
    foreach my $mod (keys %mod_instance_hash){
        my @match_priority;
        # order by priority
        foreach my $rec (@{$mod_instance_hash{$mod}}){
            my $priority = $rec->get_resolve_priority();
            if(defined $match_priority[$priority]){
                confess "conflicting resolution on modules : " . Dumper($rec) . " and " . Dumper($match_priority[$priority]);
            }
            $match_priority[$priority] = $rec;
        }
        # get highest priority
        $self->add_record(pop @match_priority);
    }
}

1;
