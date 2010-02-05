#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'App::Autopod' );
}

diag( "Testing App::Autopod $App::Autopod::VERSION, Perl $], $^X" );
