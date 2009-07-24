use inc::Module::Install;

name 'Fuse-Template';
all_from 'lib/Fuse/Template.pm';

requires 'Moose' => 0.80;
requires 'Fuse'  => 0.09;
requires 'Fcntl' => 1.00;

test_requires 'Test::More' => 0;

auto_install;
WriteAll;
