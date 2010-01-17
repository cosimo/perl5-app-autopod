#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'App::autopod' );
}

diag( "Testing App::autopod $App::autopod::VERSION, Perl $], $^X" );
