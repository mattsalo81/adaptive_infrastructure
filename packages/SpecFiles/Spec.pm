package Spec;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;

my $comment_start = "# ";
my $comment_end = " #";
my $max_width = 80;
my $comment_width = ($max_width - length($comment_start . $comment_end));
my         $entry_format = '%-22s  %d   %-10G  %-10G  %d  %-2d';
my $comment_entry_format = '%-20s  %d   %-10G  %-10G  %d  %-2d';

sub new{
    my ($class) = @_;
    my $text = "";
    my $self = \$text;
    return bless $self, $class
}

sub add_horizontal_rule{
    my ($self) = @_;
    $$self.= $comment_start . ("=" x $comment_width) . $comment_end . "\n";
}

sub add_blank_lines{
    my ($self, $num) = @_;
    $num = 1 unless defined $num;
    $$self .= "\n" x $num;
}

sub comment{
    my ($self, $text) = @_;
    $text = "" unless defined $text;
    $$self .= $comment_start . sprintf("%-${comment_width}s", $text) . $comment_end . "\n";
}

# puts the text into a wrapped box
# preserves intratext newlines
# preserves leading whitespace after newlines
# preserves whitespace between words
sub wrap_comment{
    my ($self, $text) = @_;
    # print the header
    $self->add_horizontal_rule();
    $self->comment("");
    # remove any trailing/leading newlines
    $text =~ s/^(\s*\n)*//s;
    $text =~ s/[\n\s]*$//s;
    # split text into newlines
    my @lines = split(/\n/, $text);
    foreach my $line (@lines){
        # a block is either a word or whitespace
        my @blocks = split(/\b/, $line);
        my $wrap_line = "";
        my $non_word_block = "";
        # add blocks to the line until we no longer can
        foreach my $block (@blocks){
            my $block_len = length $block;
            if ($block !~ m/^\s+$/){
                if (length($wrap_line . $non_word_block . $block) <= $comment_width){
                    # add the word (and preceding whitespace) to the line
                    $wrap_line .= $non_word_block . $block;
                }else{
                    # comment the current line
                    $self->comment($wrap_line);
                    # add the word (and not preceding whitespace) to the next line
                    $wrap_line = $block;
                }
                # reset the preceding whitespace
                $non_word_block = "";
            }else{
                # store the whitespace block
                $non_word_block .= $block;
            }
        }
        $self->comment($wrap_line);
    }
    $self->comment("");
    $self->add_horizontal_rule();
}

# comments an entry
# maintains proper spacing
# strikes through spec for easier reading
sub add_comment_entry{
    my ($self, $entry) = @_;
    my $unstruck = sprintf("$comment_entry_format", @{$entry});
    $unstruck = sprintf("%-${comment_width}s", $unstruck);
    my $struck = $unstruck;
    $struck =~ s/\s/=/g;
    $$self .= $comment_start . $struck . $comment_end . "\n";
}

sub add_entry{
    my ($self, $entry) = @_;
    my $text = sprintf("$entry_format", @{$entry});
    $text =~ s/\s*$//;
    $$self .= $text . "\n";
}

sub get_text{
    my ($self) = @_;
    return $$self;
}

1;
