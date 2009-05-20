#!perl -T

use Test::More tests => 2;

BEGIN {
	use_ok( 'Spark::Form::Manual' );
        use_ok( 'Spark::Form::Manual::Tutorial::GettingStarted' );
}

diag( "Testing Spark::Form::Manual $Spark::Form::Manual::VERSION, Perl $], $^X" );
