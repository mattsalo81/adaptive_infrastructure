package TiedStream;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;

# WARNING : do NOT print anything to STDOUT or STDERR in this package.  
#           It's designed to reopen STDOUT and STDERR, so you WILL get caught in a loop
#	    Thanks,  Matt

our $all_streams = "";

sub TIEHANDLE{
	my ($class) = @_;
	bless [""], $class;
}

sub FETCH{
	my ($self) = @_;
	confess "Something went wrong" unless ref $self;
	return $self;	
}

sub PRINT{
	my $self = shift;
	$self->[0] .= join("", @_);
	$all_streams .= join("", @_);
}

sub PRINTF{
	my $self = shift;
	my $fmt = shift;
	my $text = sprintf($fmt, @_);
	$self->[0] .= $text;
	$all_streams .= $text;
}

sub READLINE{
	my $self = shift;
	return $self->[0];
}

sub has_contents{
	my ($self) = @_;
	confess "Something went wrong" unless ref $self;
	return ($self->[0] eq "");
}

1;
