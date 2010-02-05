#!perl -T

use strict;
use warnings;
use Test::More qw(no_plan);

BEGIN {
	use_ok( 'App::Autopod' );
}

for (glob("t/get-subs/*.test"), glob("get-subs/*.test")) {

	# Slurp in test file content
	my $test_file = $_;
	open my $fh, '<', $test_file or die "Could not open test file $test_file: $!\n";
	my @test_content = <$fh>;
	close $fh;

	# List of expected subs is at the start of the file
	# First blank line ends the list
	my @expected_subs = ();
	while (@test_content) {
		chomp (my $line = shift @test_content);
		last unless $line;
		push @expected_subs, $line;
	}

	my @found_subs = App::Autopod::get_subs_from_source(@test_content);

	# Compare what we found with the expected result
	is_deeply(
		\@found_subs => \@expected_subs,
		qq(Test file '$test_file' subroutines parsing succeeded)
	);

}

