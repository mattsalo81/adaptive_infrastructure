use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use SMS::SMSDigest;
use SpecFiles::GenerateSpec;

my ($parm, $num, $lsl, $usl, $io, $dispo) = (0,1,2,3,4,5);
my $inf = 9e9;

my %skip;
if (open my $override, "./overrides"){
    while (<$override>){
        chomp;
        s/\s*//g;
        s/#.*//;
        $skip{$_} = 1;
        warn "overriding <$_>\n";
    }
    close $override;
}

main();

sub main{
    my ($technology) = @ARGV;
    unless (defined $technology){
        die "Usage :      $0 <technology>\n\n";
    }
    my $specfile_info = load_spec($technology);
    analyze_differences($specfile_info);
    
}

sub load_spec{
    my ($technology) = @_;
    my $records = SMSDigest::get_entries_for_tech($technology);
    my %hash;
    foreach my $rec (@{$records}){
        my $dev  = $rec->get("DEVICE");
        my $lpt  = $rec->get("LPT");
        my $opn  = $rec->get("OPN");
        my $prog = $rec->get("PROGRAM");
        my $tech = $rec->get("TECHNOLOGY");
        my $effr = $rec->get("EFFECTIVE_ROUTING");
        my $area = $rec->get("AREA");
        my $key = "$dev $lpt $opn $prog";
        eval{
            my $specfile = "/usr1/testware/scraptest/$prog/$prog.spec";
            my $old = load_specfile($specfile);
            my $new_spec = GenerateSpec::get_spec($tech, $area, $effr, $prog);
            my $new = read_spec($$new_spec);
            $hash{$key} = [$old, $new];
            1;
        } or do {
            my $e = $@;
            print "Problem with <$key> : $e";
        };
    }
    return \%hash;
}

sub analyze_differences{
    my ($specfile_structure) = @_;
    my $num_files = scalar keys %{$specfile_structure};
    my %partial_spec_comp;
    my %turned_on;
    my %turned_off;
    my %program_issues;
    my %issues;
    
    # value differences... LSL, USL, IO, etc.
    PROGRAM:foreach my $program (keys %{$specfile_structure}){
        my ($old, $new) = @{$specfile_structure->{$program}};
        # create a master list of parm-ids that show up
        my %master_list;
        @master_list{keys %{$old}} = keys %{$old};
        @master_list{keys %{$new}} = keys %{$new};
        PARMID:foreach my $parm_id (keys %master_list){
            next if defined $skip{$program . "-" . "*"     };
            next if defined $skip{"*"      . "-" . $parm_id};
            next if defined $skip{$program . "-" . $parm_id};
            my ($o, $n) = (defined $old->{$parm_id}, defined $new->{$parm_id});
            if (!$o &&  $n){
                $turned_on{$parm_id} = [] unless defined $turned_on{$parm_id};
                push @{$turned_on{$parm_id}}, $program;
                $program_issues{$program} = [] unless defined $program_issues{$program};	
                push @{$program_issues{$program}}, "$parm_id turned_on_in_component_specfile";
            }  	# flag as turned on	
            if ( $o && !$n){
               $turned_off{$parm_id} = [] unless defined $turned_off{$parm_id};
               push @{$turned_off{$parm_id}}, $program;
               $program_issues{$program} = [] unless defined $program_issues{$program};
               push @{$program_issues{$program}}, "$parm_id turned_off_in_flow_specfile";
            }       # flag as turned on
        }
    }
    print "program,num_issues,issue\n";
    foreach my $program (sort keys %program_issues){
        my $num_issues = scalar @{$program_issues{$program}};
        foreach my $issue (sort @{$program_issues{$program}}){
            print "$program,$num_issues,$issue\n";
        }
    }
    my @master_program;
    my %programs_turned;
    foreach my $prog_list (values %issues){
        @programs_turned{@{$prog_list}} = @{$prog_list};
    }
    @master_program = sort keys %programs_turned;
    print "\n"x 5 ."issue,num_progs," . join(',', @master_program) . "\n";
        foreach my $issue (sort keys %issues){
                print "$issue," . scalar @{$issues{$issue}};
                my %turned;
                @turned{@{$issues{$issue}}} = @{$issues{$issue}};
                foreach my $prog (@master_program){
                        print "," . (defined $turned{$prog} ? "1" : "0");
                }
                print "\n";
        }

    %programs_turned = ();	
        foreach my $prog_list (values %turned_on){
                @programs_turned{@{$prog_list}} = @{$prog_list};
        }
    @master_program = sort keys %programs_turned;
    print "\n"x 5 . "parm,num_turned_on," . join(',', @master_program) . "\n";
    foreach my $parm_id (sort keys %turned_on){
        print "$parm_id," . scalar @{$turned_on{$parm_id}};
        my %turned;
        @turned{@{$turned_on{$parm_id}}} = @{$turned_on{$parm_id}};
        foreach my $prog (@master_program){
            print "," . (defined $turned{$prog} ? "1" : "0");
        }
        print "\n";
    }
    
    %programs_turned = ();
        foreach my $prog_list (values %turned_off){
                @programs_turned{@{$prog_list}} = @{$prog_list};
        }
    @master_program = sort keys %programs_turned;
    print "\n"x 5 . "parm,num_turned_off," . join(',', @master_program) . "\n";
        foreach my $parm_id (sort keys %turned_off){
                print "$parm_id," . scalar @{$turned_off{$parm_id}};
                my %turned;
                @turned{@{$turned_off{$parm_id}}} = @{$turned_off{$parm_id}};
                foreach my $prog (@master_program){
                        print "," . (defined $turned{$prog} ? "1" : "0");
                }
                print "\n";
        }

        %programs_turned = ();
        foreach my $prog_list (values %partial_spec_comp){
                @programs_turned{@{$prog_list}} = @{$prog_list};
        }
        @master_program = sort keys %programs_turned;
}

sub load_specfile{
    my ($file) = @_;
    open my $fh, $file or die "could not open <$file>\n";
        my @lines = <$fh>;
    close $fh;
    return read_spec(@lines);
}

sub read_spec{
    my (@lines) = @_;
    @lines = map {split(/\n/, $_)} @lines;
    my %hash;
    foreach $_ (@lines){
        chomp;
        next if m/^\s*$/;
        s/^\s*//;
        next if m/^#/;
        my @line = split /\s+/;
        if (scalar @line != 6){
                warn "line <$_> is malformed\n";
                next;
        }
        my $key = $line[$parm] . "." . $line[$dispo];
        warn "duplicate entry found for <$key>\n" if defined $hash{$key};
        $hash{$key} = \@line;
    }
    return \%hash;
}
