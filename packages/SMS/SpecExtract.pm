package SpecExtract;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use EffectiveRouting::Generate;
use DBI;
use Database::Connect;
use Carp;
use Data::Dumper;
use Logging;

# this package contains all the information needed to create an extrat of all devices + their common specs.
# this extract should be referenced if at all possible, instead of rewriting a similar SMS query elsewhere
# If information is not in the table, but could be and is needed elsewhere, this table should be updated to include it
# 
# This package uses EffectiveRouting generators to create the EffectiveRouting attribute.  The Effective Routing will be used
# to generate KLF names/determine process codes, so should be unique to the process options included

my %family2tech;
my %lpt_opn2area;

sub update_sms_table{
    my $table = 'daily_sms_extract';
    my $trans = Connect::new_transaction("etest");
    eval{
        # empty table in transaction
        Logging::event("Clearing old sms extract table");
        my $e_sth = $trans->prepare("delete from $table where 1 = 1");
        $e_sth->execute();

        # get SMS data
        Logging::event("Downloading info from SMS and putting it into etest db");
        my $d_sth = get_device_extract_handle();
        $d_sth->execute();

        # prepare upload handle and bind variables
        my $u_sql = qq{
            insert into $table (DEVICE, TECHNOLOGY, FAMILY, COORDREF, ROUTING, 
                        EFFECTIVE_ROUTING, LPT, COT, PROGRAM, 
                        PROBER_FILE, RECIPE, AREA, OPN, CARD_FAMILY, DEV_CLASS, PROD_GRP) values 
                        (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        };
        my $u_sth = $trans->prepare($u_sql);
        my ($device, $technology, $family, $coordref, $routing, $effective_routing, $lpt, 
            $cot, $program, $prober_file, $recipe, $area, $opn, $card_family, $dev_class, $prod_grp);
        
        my $num = 0;
        # enter the download/scrub/upload loop
        while (my $rec = $d_sth->fetchrow_hashref("NAME_uc")){
            eval{	
                no warnings q{exiting};
                $device = $rec->{"DEVICE"};
                Logging::diag("Processing device $device");
                Logging::diag(Dumper($rec));
                $num++;
                if ($num % 100 == 0){
                    Logging::event("Processed $num devices");
                }

                # error checking on KPARMS
                $rec->{"AREA"} = get_area_from_lpt_and_opn($rec->{"LPT"}, $rec->{"OPN"});
                $area = $rec->{"AREA"};
                next if $area eq "UNDEF";

                # set bound variables
                $family = $rec->{"FAMILY"};
                $rec->{"TECHNOLOGY"} = get_technology_from_family($family);
                $technology = $rec->{"TECHNOLOGY"};
                $coordref = $rec->{"COORDREF"};
                next unless defined $coordref;
                $routing = $rec->{"ROUTING"};
                $lpt = $rec->{"LPT"};
                $program = $rec->{"PROGRAM"};
                next unless defined $program;
                $prober_file = $rec->{"PROBER_FILE"};
                next unless defined $prober_file;
                $opn = $rec->{"OPN"};
                $card_family = $rec->{"CARD_FAMILY"};
                next unless defined $card_family;
                $cot = get_COT_from_record($rec);
                $recipe = make_recipe_from_record($rec);
                $dev_class = $rec->{"CLASS"};
                $prod_grp = $rec->{"PROD_GRP"};
                
                $effective_routing = EffectiveRouting::Generate::make_from_sms_hash($rec);
                $rec->{"AREA"} = get_area_from_lpt_and_opn($rec->{"LPT"}, $rec->{"OPN"});
                $area = $rec->{"AREA"};
                # error checking on KPARMS
                next if $area eq "UNDEF";

                # upload
                $u_sth->execute($device, $technology, $family, $coordref, $routing, $effective_routing, $lpt, 
                        $cot, $program, $prober_file, $recipe, $area, $opn, $card_family, $dev_class, $prod_grp);
                1;
            } or do {
                my $e = $@;
                Logging::error($e);
            }
        }
        
        $trans->commit();
        1;
    } or do {
        my $e = $@;
        $trans->rollback();
        confess "Could not update daily sms extract! : <$e>\n";
    }
}

sub get_COT_from_record{
    my ($hash_rec) = @_;
    my $prod_grp = $hash_rec->{"PROD_GRP"};
    unless (defined $prod_grp){
        confess("Unable find <PROD_GRP> in this record : " .  Dumper($hash_rec) . "\n");
    }
    if ($prod_grp =~ m/COT/i){
        Logging::debug("It's a COT device");
        return 'Y';
    }else{
        return 'N';
    }
    return undef;
}

sub make_recipe_from_record{
    my ($rec) = (@_);
    return make_recipe($rec->{"FAMILY"}, $rec->{"ROUTING"}, $rec->{"PROGRAM"});
}

sub make_recipe{
    my ($family, $routing, $program) = @_;
    $family = "" unless defined $family;
    $routing = "" unless defined $routing;
    $program = "" unless defined $program;
    unless ($family ne "" && $routing ne "" && $program ne ""){
        confess("Could not make recipe with <$family> <$routing> and <$program>\n");
    }
    $routing = clean_text($routing);
    return "${family}__${routing}__${program}";
}

sub clean_text{
    my ($text) = @_;
    my $orig_text = $text;
    $text =~ tr{-\./\+}{desp};
    $text =~ s/\s//g;
    unless ($text =~ m/^[a-zA-Z0-9]*$/){
        confess "Could not clean <$orig_text>! Best try : <$text>.  Probably need to update the naming conventions\n";
    }
    return $text;
}

sub get_technology_from_family{
    my ($family) = @_;
    $family =~ tr/[a-z]/[A-Z]/;
    unless (defined $family2tech{$family}){
        Logging::debug("Looking for technology for $family in etest db");
        my $conn = Connect::read_only_connection("etest");
        my $sql = "select technology from family_to_technology where UPPER(family) = ?";
        my $sth = $conn->prepare($sql);
        $sth->execute($family);
        my ($technology) = $sth->fetchrow_array();
        unless (defined $technology){
            $technology = "UNDEF";
        }
        $family2tech{$family} = $technology;
    }
    return $family2tech{$family};
} 

sub get_area_from_lpt_and_opn{
    my ($lpt, $opn) = @_;
    unless(defined $lpt and defined $opn){
        confess "Critical info not provided to find test area";
    }

    my $key = "$lpt" . "x" . "$opn";
    unless (defined $lpt_opn2area{$key}){
        Logging::debug("Looking for test area for lpt:opn $lpt:$opn in etest db");
        my $sql = "select test_area from etest_logpoints where logpoint = ? and operation = ?";
        my $conn = Connect::read_only_connection("etest");
        my $sth = $conn->prepare($sql);
        $sth->execute($lpt, $opn);
        my ($area) = $sth->fetchrow_array();
        $area = "UNDEF" unless defined $area;
        $lpt_opn2area{$key} = $area;		
    }
    return $lpt_opn2area{$key};
}

sub get_parametric_logpoints_operations{
    my $conn = Connect::read_only_connection("etest");
    my $sql = q{
        select distinct LOGPOINT, OPERATION from etest_logpoints
    };
    my $sth = $conn->prepare($sql);
    $sth->execute();
    my %lpt;
    my %opn;
    while( my $rec = $sth->fetchrow_arrayref()){
        $lpt{$rec->[0]} = "yep";
        $opn{$rec->[1]} = "yep";
    }
    return ([keys %lpt], [keys %opn]);
}

sub get_device_extract_handle{
    my $conn = Connect::read_only_connection("sms");
    my ($lpt, $opn) = get_parametric_logpoints_operations();
    $lpt = [map {"'$_'"} @{$lpt}];
    $opn = [map {"'$_'"} @{$opn}];
    $lpt = join(", ", @{$lpt});
    $opn = join(", ", @{$opn});
    unless($lpt =~ m/^'[0-9]{4}'(, '[0-9]{4}')*$/ && $opn =~ m/^'[0-9]{4}'(, '[0-9]{4}')*$/){
        confess "logpoint and operation strings are in unexpected format! : <$lpt> <$opn>";
    }
    my $extract_sql = qq{
    select 
      dm.device, 
      dm.class,
      dm.family,
      dm.prod_grp,
      dm.fe_stratgy as fe_strategy,
      dm.routing,
      rfd.lpt,
      rfd.opnset,
      ofd.opn,
      kparm_resolve(dm.facility, dm.device, '704', '7160', rfd.lpt, ofd.opn, '704') as program,
      kparm_resolve(dm.facility, dm.device, '704', '7162', rfd.lpt, ofd.opn, '704') as prober_file,
      kparm_resolve(dm.facility, dm.device, '704', '7161', rfd.lpt, ofd.opn, '704') as card_family,
      kparm_resolve(dm.facility, dm.device, '704', '5300', '0000', '0000', '704') as coordref
      
    from 
      smsdw.dm_device_attributes dm
      inner join smsdw.routing_def rd
        on  rd.facility = dm.facility
        and rd.routing = dm.routing
        and rd.status = 'A'
      inner join smsdw.routing_flw_def rfd
        on  rfd.facility = rd.facility
        and rfd.routing = rd.routing
        and rfd.rev = rd.rev
        and rfd.lpt in ($lpt)
      inner join smsdw.opnset_def od
        on  od.facility = rfd.facility
        and od.opnset = rfd.opnset
        and od.status = 'A'
      inner join smsdw.opnset_flw_def ofd
        on  ofd.facility = od.facility
        and ofd.opnset = od.opnset
        and ofd.rev = od.rev
        and ofd.opn in ($opn)
    where 
      dm.facility = 'DP1DM5'
      and dm.status = 'A'
      and (dm.prod_grp in ('PRIME', 'DEV') or dm.dev_group in ('PRIME', 'DEV'))
      and dm.device not like '%DMD%'
      and dm.device not like '%MX'
      and dm.device not like 'M/%'
    };
    my $sth = $conn->prepare($extract_sql);
    return $sth;
}

1;
