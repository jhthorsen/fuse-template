#!perl

use strict;
use warnings;
use lib q(./lib);
use Fcntl qw/O_RDONLY/;
use Fuse::Template;
use Test::More;

plan tests => 6;

use_ok("Fuse::Template");

my $sqlite = "t/data/test.db";
my $mountpoint = "/tmp/fuse-template";
my $root = "t/templates";
my $obj = Fuse::Template->new(
              root => $root,
              mountpoint => $mountpoint,
              mountopts => "allow_other",
              schema => "dbi:SQLite:$sqlite",
              debug => 0,
          );

ok(!$obj->open("users.cfg", O_RDONLY), "file found");

my $data = $obj->read("users.cfg", 8096, 0);
ok(length $data > 10, "file read");
like($data, qr{ola}, "'ola' in file");

