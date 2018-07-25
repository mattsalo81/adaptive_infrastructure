package SMS::Consolidate;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;

# this package solves the problem of consolidating multiple records into smaller blocks that accurately summarize the records
# If you had a list of 1000 device/opn/lpts, can you consolidate that list into device/test_area? program/test_area?  effective_routing/testarea?

# if you're refering to a list of devices all on the same program, could you just as accurately say "every device on this program"?  You'd have to check all the other devices, to see if there are any devices not in your original list.  If there are no other devices on that program, you can consolidate your original list of devices to just "every device on this program".

# this routine takes a master list of all devices/info, a subset of devices, and a list of consolidation fields
# the consolidation fields correspond to information fields in the master list of devices
# the subroutine determines if for every particular, unique combination of the consolidation field values, the subset device list contains every device
# (ie, if consolidating by "PROGRAM", see if every device with some program value is in the subset device list)
# if a consolidation is found, then all devices that match that consolidation is droped from the subset list and only the consolidation is added to the consol list.
# subroutine returns unconsolidated dev/lpt/opn and consolidated values.
# (ie, if the master table is [D1 w/ P1, D2 w/ P1, D3 w/ P2, D4 w/ P2], and you give [D1, D2, D3] and consolidate by PROGRAM, then you'd consolidate D1/D2 onto P1 and leave D3 unconsolidated.  D3 is not consolidated because there exists some device D4 on the same program that is not in the device subset.  Return value in this case would be ([D3], [P1]))

# consolidation_fields is an arrayref of fields to use
# ["EFFECTIVE_ROUTING", "AREA"] etc
sub consolidate{
    my ($sms_records, $dev_lpt_opn_list, $consolidation_fields) = @_;
    my $sep = "xXxXx";
    my @matched_consolidations;
    # create a lookup to the $dev_lpt_opn_list
    my %input_lookup;
    foreach my $dev_lpt_opn (@{$dev_lpt_opn_list}){
        my $dev = $dev_lpt_opn->{"DEVICE"};
        my $lpt = $dev_lpt_opn->{"LPT"};
        my $opn = $dev_lpt_opn->{"OPN"};
        confess "DEVICE not defined" unless defined $dev;
        confess "LPT not defined" unless defined $lpt;
        confess "OPN not defined" unless defined $opn;
        my $key = $dev . " " . $lpt . " " . $opn;
        $input_lookup{$key} = $dev_lpt_opn;
    }
    # create a lookup for the records
    my %record_lookup;
    foreach my $sms_rec (@{$sms_records}){
        my @consolidation_keys;
        foreach my $consolidation_field (@{$consolidation_fields}){
            push @consolidation_keys, $sms_rec->get($consolidation_field);
        }
        my $consolidation_key = join($sep, @consolidation_keys);
        $record_lookup{$consolidation_key} = {} unless defined $record_lookup{$consolidation_key};
        my $dev_lpt_opn = $sms_rec->get("DEVICE") . " " . $sms_rec->get("LPT") . " " . $sms_rec->get("OPN");
        $record_lookup{$consolidation_key}->{$dev_lpt_opn} = 1;

    }
    # determine which lookups are fully satisfied
    foreach my $consolidation_key (keys %record_lookup){
        my @matched;
        my @missing;
        my @all_rec_on_consol = keys %{$record_lookup{$consolidation_key}};
        foreach my $rec_on_consol (@all_rec_on_consol){
            # classify the desired record as either in the input list or missing from the input list
            if (defined $input_lookup{$rec_on_consol}){
                push @matched, $rec_on_consol;
            }else{
                push @missing, $rec_on_consol;
            }
        }
        # if nothing missing
        if (scalar @missing == 0){
            foreach my $rec_on_consol (@matched){
                # remove it from the input list
                delete $input_lookup{$rec_on_consol};
            }
            my @consolidation_fields = split($sep, $consolidation_key);
            push @matched_consolidations, \@consolidation_fields;
        }
    }
    # return
    my @unmatched_dev_lpt_opn = values %input_lookup;
    return (\@unmatched_dev_lpt_opn, \@matched_consolidations);
}



1;
