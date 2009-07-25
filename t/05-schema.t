#!perl

use strict;
use warnings;
use Test::More;
use lib q(./lib);
use Fuse::Template;

plan tests => 6;

my $sqlite = "t/data/test.db";
my %args = (
    root => "/foo",
    mountpoint => "/bar",
    debug => 0,
);
my($obj, $schema, $rs, $row);

$obj = Fuse::Template->new(%args, schema => "dbi:SQLite:$sqlite");
ok($schema = $obj->schema, "schema loaded with string");

$obj = Fuse::Template->new(%args, schema => { dsn => "dbi:SQLite:$sqlite" });
ok($schema = $obj->schema, "schema loaded with hashref");

is(scalar($schema->sources), 1, "sources found");
ok($rs = $schema->resultset('Users'), "resultset Users found");

ok($row = $rs->find(1), "row found");
is($row->username, "ola", "user ola found");

