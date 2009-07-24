#!perl

use strict;
use warnings;
use Test::More;
use lib q(./lib);
use Fuse::Template;
use Fcntl qw/O_RDONLY/;

plan tests => 9;

my $mountpoint = "/tmp/fuse-template";
my $root = "t/templates";

my $obj = Fuse::Template->new(
              root => $root,
              mountpoint => $mountpoint,
              debug => 0,
          );

is($obj->root, $root, "root path");

my @stat = $obj->getattr('/');
is($stat[2], 16877, "root mode");
is($stat[7], 4096, "root size");

ok(!$obj->readlink('foo'), "foo is not a link");

my @list = sort $obj->getdir("/");
is($list[0], '.', "dir contains self ref");
is($list[1], '..', "dir contains parent ref");
ok(scalar(grep { $_ eq 'plain.txt' } @list), "plain.txt is found in dir");

ok(!$obj->open("/plain.txt", O_RDONLY), "open plain.txt successful");
ok($obj->read("/plain.txt", 1024, 0), "read plain.txt successful");

