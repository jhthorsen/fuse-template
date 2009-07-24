use inc::Module::Install;

name 'Fuse-Template';
all_from 'lib/Fuse/Template.pm';

requires 'Moose' => 0.80;
requires 'MooseX::Types' => 0.16;
requires 'DBIx::Class' => 0.08;
requires 'DBIx::Abstract' => 1.00;
requires 'DBIx::Schema' => 0.07;
requires 'Fuse' => 0.09;
requires 'Fcntl' => 1.00;

test_requires 'Test::More' => 0;

auto_install;
WriteAll;
