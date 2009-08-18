use inc::Module::Install;

name 'Fuse-Template';
all_from 'lib/Fuse/Template.pm';

requires 'Moose' => 0.80;
requires 'MooseX::Types' => 0.16;
requires 'MooseX::Getopt' => 0.18;
requires 'DBIx::Class' => 0.08;
requires 'DBIx::Class::Schema::Loader' => 0.04;
requires 'Fuse' => 0.09;
requires 'Template' => 2.0;

test_requires 'DBD::SQLite' => 1.0;
test_requires 'File::Find' => 1.0;
test_requires 'Test::More' => 0.8;
test_requires 'Test::Pod' => 1.2;
test_requires 'Test::Pod::Coverage' => 1.0;

auto_install;
WriteAll;
