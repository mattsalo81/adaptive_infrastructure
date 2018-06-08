use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use SpecFiles::Spec;

# constructor
my $spec = Spec->new();
ok(defined $spec, "got a blank specfile");
is(ref($spec), "Spec", "Specfile object of type Spec");
is($spec->get_text(), "", "Specfile has nothing in it when created");

# horizontal rule
$spec->add_horizontal_rule();
ok($spec->get_text() =~ m/^# =+ #\n$/s, "Horizonal rule expected format");
$spec->add_horizontal_rule();
ok($spec->get_text() =~ m/^(# =+ #)\n\1\n$/s, "Two horizonal rules");

# blank lines
$spec = Spec->new();
$spec->add_blank_lines();
is($spec->get_text(), "\n", "Added default 1 blank line");
$spec->add_blank_lines(10);
is($spec->get_text(), "\n" x 11, "Added 10 blank line");

# entries
$spec = Spec->new();
$spec->add_entry(["PARM", 1, "100", "200", 1, 2]);
ok($spec->get_text() =~ m/^PARM\s+1\s+100\s+200\s+1\s+2\s*\n$/s, "Entry looks like a specline");
$spec->add_comment_entry(["PARM", 1, "100", "200", 1, 2]);
$spec->get_text() =~ m/^PARM  (\s+1\s+100\s+200\s+1\s+2)\s*\n/;
my $match = $1;
$match =~ s/\s/=/g;
ok($spec->get_text() =~ m/^PARM  (\s+1\s+100\s+200\s+1\s+2)\s*\n# PARM$match=* #\n$/s, "Comment entry looks like a specline and has similar spacing.");

# Comments
$spec = Spec->new();
$spec->comment("This is a comment");
ok($spec->get_text() =~ m/^# This is a comment *#\n$/s, "Comment looks good");

# Wrap comments
$spec = Spec->new();
$spec->wrap_comment(q{
    This                    is a very long comment that is going to be interesting to see
how the engine wraps the comment around the max length



});
my $wrapped = q{
# ======================================================== #
#                                                          #
#     This                    is a very long comment that  #
# is going to be interesting to see                        #
# how the engine wraps the comment around the max length   #
#                                                          #
# ======================================================== #
};
is("\n" . $spec->get_text(), $wrapped, "Wrapped text successfully");

# comprehensive tests
$spec = Spec->new();
$spec->wrap_comment(q{
    Program       : M06ECD65310
    Device String : AAAAANwsod8\sjdglk
    Waivers       : Yes
});
$spec->add_blank_lines(2);
$spec->comment("PCH_HV5 Component");
$spec->add_entry(["PARM", 1, "100", "200", 1, 2]);
$spec->add_entry(["PARM2", 2, "-100", 9e99, 1, 6]);
$spec->add_blank_lines(1);
$spec->comment("NCH_HV5 Component");
$spec->add_entry(["NARM", 1, "100", "200", 1, 2]);
$spec->comment("Waived because of reasons");
$spec->add_comment_entry(["NARM2", 2, "-100", 9e99, 1, 6]);
$spec->add_entry(["NARM2", 2, "-150", 9e99, 1, 6]);
$spec->add_blank_lines(1);

my $expected = q{
# ======================================================== #
#                                                          #
#     Program       : M06ECD65310                          #
#     Device String : AAAAANwsod8\sjdglk                   #
#     Waivers       : Yes                                  #
#                                                          #
# ======================================================== #


# PCH_HV5 Component                                        #
PARM                    1   100         200         1  2
PARM2                   2   -100        9E+99       1  6

# NCH_HV5 Component                                        #
NARM                    1   100         200         1  2
# Waived because of reasons                                #
# NARM2=================2===-100========9E+99=======1==6== #
NARM2                   2   -150        9E+99       1  6

};

is("\n" . $spec->get_text(), $expected, "Tried out all the features and got what I expected");
