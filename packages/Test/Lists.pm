sub in_list{
    my ($test_element, $list) = @_;
    my $found;
    foreach my $element (@{$list}){
        return 1 if ($element eq $test_element);
    };
    return 0;
}

sub lists_identical{
    my ($list1, $list2) = @_;
    return 0 unless(scalar @{$list1} == scalar @{$list2});
    for(my $i = 0; $i < scalar @{$list1}; $i++){
        return 0 unless($list1->[$i] eq $list2->[$i]);
    }
    return 1;
}

sub have_same_elements{
    my ($list1, $list2) = @_;
    my @sort1 = sort @{$list1};
    my @sort2 = sort @{$list2};
    return lists_identical(\@sort1, \@sort2);
}

sub hashes_identical{
    my ($hash1, $hash2) = @_;
    return 0 unless(scalar keys %{$hash1} == scalar keys %{$hash2});
    my @hash1 = map {($_, $hash1->{$_})} sort keys %{$hash1};
    my @hash2 = map {($_, $hash2->{$_})} sort keys %{$hash2};
    return lists_identical(\@hash1, \@hash2);
}

1;
