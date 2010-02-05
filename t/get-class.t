#!perl -T

use Test::More qw(no_plan);

BEGIN {
	use_ok( 'App::Autopod' );
}

for (glob("t/get-class/*.test"), glob("get-class/*.test")) {

	# Slurp in test file content
	my $test_file = $_;
	open my $fh, '<', $test_file or die "Could not open test file $test_file: $!\n";
	my @test_content = <$fh>;
	close $fh;

	chomp (my $expected_package = shift @test_content);
	my $found_package = App::Autopod::get_class_from_source(@test_content);

	if ($expected_package =~ s/^!//) {
		isnt(
			$found_package => $expected_package,
			"Test file $test_file should *not* have package '$expected_package'"
		);
	}
	else {
		is(
			$found_package => $expected_package,
			"Test file $test_file has package '$expected_package'"
		);
	}

}

