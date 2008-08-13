#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'String::Comments::Extract' );
}

diag( "Testing String::Comments::Extract $String::Comments::Extract::VERSION, Perl $], $^X" );
