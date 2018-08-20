package Database::CSV;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;
use Database::PrimaryKeys;

my $default = undef;

sub upload_csv{
    my ($database, $table, $csv) = @_;
    my $primary_keys = PrimaryKeys::get_primary_key_attributes($database, $table);
    if (scalar @{$primary_keys} == 0){
        confess "Could not get any primary key attributes for <$table> in <$database>.  Please define an explicit primary key (UNIQUE will not work) for this table";
    }   
    my $data = parse_csv($csv);
    my $first = $data->[0];
    unless (defined $first){
        confess "Could not extract any data from <$csv>";
    }
    # get a list of all attributes
    my @csv_attr = keys %{$first};
    my %csv_attr;
    @csv_attr{@csv_attr} = @csv_attr;
    my @missing_keys;
    foreach my $primary (@{$primary_keys}){
        unless (defined $csv_attr{$primary}){
            push @missing_keys, $primary;
        }
    }
    if(scalar @missing_keys > 0){
        confess "Some primary keys for <$table> are missing from <$csv> : " . 
                 join(", ", @missing_keys) . ". These must be included";
    }
    # generate statement handles
    my $trans = Connect::new_transaction($database);
    my $up_sth = generate_update_sth($trans, $table, \@csv_attr, $primary_keys);
    my $ins_sth = generate_insert_sth($trans, $table, \@csv_attr);
    my $sel_sth = generate_select_sth($trans, $table, $primary_keys);
    eval{
        foreach my $rec (@{$data}){
            if(primary_key_exists($sel_sth, $primary_keys, $rec)){
                Logging::event("Updating " . Dumper($rec));
                update($up_sth, \@csv_attr, $primary_keys, $rec);
            }else{
                Logging::event("Inserting " . Dumper($rec));
                insert($ins_sth, \@csv_attr, $rec);
            }
        }
        $trans->commit();
        1;
    } or do {
        my $e = $@;
        $trans->rollback();
        confess "Could not upload <$csv> because : $e";
    };
}


# load csv into an array of hashrefs.  Each hash corresponds to one record in the table.
# the keys of the hash correspond to the column name (defined by the header/first row)
# and the keys are uppercase
sub parse_csv{
    my ($csv) = @_;
    unless (-f $csv){
        confess "file <$csv> does not exist!";
    }
    open my $fh, "$csv" or confess "Could not open <$csv>";
    my @structure;
    # get header
    my $header = <$fh>;
    chomp $header;
    $header =~ tr/a-z/A-Z/;
    my @header = split(/,/, $header);
    # input data
    while (my $rec = <$fh>){
        chomp $rec;
        my @rec = split(/,/, $rec);
        my %hash;
        for (my $i = 0; $i < scalar @header; $i++){
            $hash{$header[$i]} = $rec[$i];
            $hash{$header[$i]} = $default if ($hash{$header[$i]} eq "");
        }
        push @structure, \%hash;
    }  
    close $fh;
    return \@structure;
}

sub generate_insert_sth{
    my ($trans, $table, $all_keys) = @_;
    my $sql = "insert into $table (";
    $sql .= join(", ", @{$all_keys});
    $sql .= ") values (";
    $sql .= join(", ", ('?') x scalar @{$all_keys});
    $sql .= ")";
    my $sth = $trans->prepare($sql);
    return $sth;
}

sub insert{
    my ($ins_sth, $all_keys, $rec) = @_;
    $ins_sth->execute(@{$rec}{@{$all_keys}});
}

sub generate_update_sth{
    my ($trans, $table, $all_keys, $primary_keys) = @_;
    my $sql = "update $table set\n";
    $sql .= join(",\n", map {"$_ = ?"} @{$all_keys});
    $sql .= "\nwhere\n";
    $sql .= join("\nAND ", map {"$_ = ?"} @{$primary_keys});
    my $sth = $trans->prepare($sql);
    return $sth;
}

sub update{
    my ($up_sth, $all_keys, $primary_keys, $rec) = @_;
    $up_sth->execute(@{$rec}{@{$all_keys}}, @{$rec}{@{$primary_keys}});
}

sub generate_select_sth{
    my ($trans, $table, $primary_keys) = @_;
    my $sql = "select * from $table where ";
    $sql .= join(" AND ", map {"$_ = ?"} @{$primary_keys});
    my $sth = $trans->prepare($sql);
    return $sth;
}

sub primary_key_exists{
    my ($sel_sth, $primary_keys, $record) = @_;
    $sel_sth->execute(@{$record}{@{$primary_keys}});
    my $rec = $sel_sth->fetchall_arrayref();
    return scalar @{$rec};
}

1;
