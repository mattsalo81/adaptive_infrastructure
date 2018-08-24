use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Keithley::File;

# initial setup
my $archive_dir = "/tmp/.adaptive_infrastructure__Keithley__Archive";
unlink glob "$archive_dir/*";
my $old_env = $ENV{"KI_KTXE_CPF"};
my $tmp_env = '/tmp/.adaptive_infrastructure__Keithley__File__test';
mkdir $tmp_env unless -d $tmp_env;
unlink glob "$tmp_env/*";
$ENV{"KI_KTXE_CPF"} = $tmp_env;
my $test_file = "project.cpf";
my $test_text = "Hello, World!";
my $archived_file = "Adaptive.gdf";
my $known_phrase = "Comment";

# project stuff
ok(! -f "$tmp_env/$test_file", "File does not exist yet in project directory");
dies_ok(sub{Keithley::File::get_text($test_file, 0)}, "Cannot get text of file that does not exist");
Keithley::File::save_text($test_file, $test_text, 0);
ok(-f "$tmp_env/$test_file", "File exists in project directory");
is(Keithley::File::get_text($test_file, 0), $test_text, "file text matches what was saved");

# archive stuff
ok(! -f "$archive_dir/$test_file", "File does not exist yet in archival directory");
dies_ok(sub{Keithley::File::get_text($test_file, 1)}, "Cannot get test of file that does not exist");
Keithley::File::save_text($test_file, $test_text, 1);
ok(  -f "$archive_dir/$test_file", "File exists in the archvial directory");
ok(Keithley::File::get_text($archived_file) =~ m/$known_phrase/, "Found known archived file");















# restore env
$ENV{"KI_KTXE_CPF"} = $old_env;
