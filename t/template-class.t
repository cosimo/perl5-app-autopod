#!perl -T

use Test::More qw(no_plan);

BEGIN {
	use_ok( 'App::Autopod' );
	use_ok( 'App::Autopod::Template' );
}

my $at = App::Autopod::Template->new();
ok($at && ref $at, 'Template class ' . ref($at) . ' created');

