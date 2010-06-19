#!/usr/bin/env perl
use lib qw(lib);
use Test::More;
plan tests => 6;
use_ok('Fuse::Template');
use_ok('Fuse::Template::App');
use_ok('Fuse::Template::Root');
use_ok('Fuse::Template::Schema');
use_ok('Fuse::Template::Sys');
use_ok('Fuse::Template::TT');
