use inc::Module::Install;

name 'Fuse-Template';
all_from 'lib/Fuse/Template.pm';

requires 'Moose' => 0.80;
requires 'MooseX::Types' => 0.16;
requires 'MooseX::Getopt' => 0.20;
requires 'DBIx::Class' => 0.08;
requires 'DBIx::Class::Schema::Loader' => 0.04;
requires 'Fuse' => 0.09;
requires 'Fcntl' => 1.00;
requires 'Template' => 2.0;

test_requires 'Test::More' => 0;

auto_install;
WriteAll;
