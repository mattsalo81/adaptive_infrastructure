use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use SMS::SMSDigest;
use SpecFiles::GenerateSpec;

my ($parm, $num, $lsl, $usl, $io, $dispo) = (0..5);
my $dir  = 'spec_audit';
my $tmp = "/tmp/$dir";

unlink glob "$tmp/*" if -d $tmp;
unlink $tmp if -d $tmp;
`mkdir $tmp`;


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
    my ($technology, $comp, $compare_dir) = @ARGV;
    unless (defined $technology){
        die qq{
            Usage :      $0 <technology> [comp] [compare_dir]
            <technology> is the new adaptive technology flag
            [comp] is 0 or 1 for cutting down specs by components, default is 1
            [compare_dir] is the directory of old specfiles (must be PROGRAM.spec) -> defaults to current PROD files
        };
    }
    $comp = 1 unless defined $comp;
    my $specfile_info = load_spec($technology, $comp, $compare_dir);
    analyze_differences($specfile_info);
    
}

sub load_spec{
    my ($technology, $comp, $compare_dir) = @_;
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
        next if $prog =~ m/^M05/;
        next if $area ne "PARAMETRIC";
        eval{
            my $specfile;
            if(defined $compare_dir){
                $specfile = "$compare_dir/$prog.spec";
            }else{
                $specfile = "/usr1/testware/scraptest/$prog/$prog.spec";
            }
            my $old = load_specfile($specfile);
            my $new_spec = GenerateSpec::get_spec($tech, $area, $effr, $prog, $comp);
            open my $fh, "> $tmp/$prog.spec" or die "could not create new spec <$tmp/$prog.spec>";
            print $fh $$new_spec;
            close $fh;
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
            my $o = defined $old->{$parm_id};
            my $n = defined $new->{$parm_id};
            if ((!$o) && ($n)){
                $turned_on{$parm_id} = [] unless defined $turned_on{$parm_id};
                push @{$turned_on{$parm_id}}, $program;
                $program_issues{$program} = [] unless defined $program_issues{$program};	
                push @{$program_issues{$program}}, "$parm_id turned_on_in_specfile";
            }  	# flag as turned on	
            if ( $o && !$n){
               $turned_off{$parm_id} = [] unless defined $turned_off{$parm_id};
               push @{$turned_off{$parm_id}}, $program;
               $program_issues{$program} = [] unless defined $program_issues{$program};
               push @{$program_issues{$program}}, "$parm_id turned_off_in_specfile";
            }       # flag as turned on
            if ($o && $n){
                my $o_l = sprintf("%s %d %g %g %d %d", @{$old->{$parm_id}});
                my $n_l = sprintf("%s %d %g %g %d %d", @{$new->{$parm_id}});
                if (($o_l ne $n_l) && (($old->{$parm_id}->[2] != $new->{$parm_id}->[2]) || ($old->{$parm_id}->[3] != $new->{$parm_id}->[3]))){
                    print "$program Limits don't match <$o_l> <$n_l>\n";
                }
            }
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
                my @prog_list = map {s/.* //; $_} @{$prog_list};
                @programs_turned{@{$prog_list}} = @prog_list;
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
                my @prog_list = map {s/.* //; $_} @{$prog_list};
                @programs_turned{@{$prog_list}} = @prog_list;
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
