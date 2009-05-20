use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Spark::Form::Manual',
    license             => 'perl',
    dist_author         => 'James Laver <printf(qw(%s@%s.com cpan jameslaver))>',
    dist_version_from   => 'lib/Spark/Form/Manual.pm',
    dist_abstract       => 'Manual for Spark::Form',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Spark-Form-Manual-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
