#!perl

use strict;
use warnings;
use Test::More;
use lib q(./lib);

plan tests => 5;

use_ok("Fuse::Template");

my $mountpoint = "/tmp/fuse-template";
my $root = "t/templates";

unless(-d $mountpoint) {
    mkdir $mountpoint or die "Could create mountpoint: $!";
}

my $obj = Fuse::Template->new(
              root => $root,
              mountpoint => $mountpoint,
              mountopts => "allow_other",
              debug => 0,
          );

ok($obj, "object constructed");
is($obj->mountpoint, $mountpoint, "mountpoint attr is set");
is($obj->find_file("plain.txt"), "$root/plain.txt", "file found");

END {
    rmdir $mountpoint;
}
