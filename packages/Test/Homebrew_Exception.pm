# I can't figure out how to install the real Test::Exception so I'm making a quick one
# alright turns out I couldn't figure out how to make this into a package (exporter didn't seem to be working)
# so just require this instead of use it

sub dies_ok{
	my ($func, $text) = @_;
	eval{
		$func->();
		ok(0, "Did not Die : $text");
	} or do {
		ok(1, "Died successfully : $text");
	};
}

sub throws_ok{
        my ($func, $regex, $text) = @_;
        eval{
                $func->();
                ok(0, "Did not Die : $text");
        } or do {
		my $e = $@;
		if ($e =~ m/$regex/){
			ok(1, "Threw Successfully : $text");
		}else{
                	ok(0, "$text : Expected m/$regex/ got $e");
		}
        };
}
1;
