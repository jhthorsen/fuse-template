package Fuse::Template::Schema;

=head1 NAME

Fuse::Template::Schema

=head1 SYNOPSIS

 use Fuse::Template::Schema qw/Schema/;

 # will import Schema typeconstraint
 use Fuse::Template::Root qw/Schema/;
 has foo => ( isa => Schema, coerce => 1 );
 ...

=cut

use Moose;
use MooseX::Types -declare => [qw/Schema/];
use DBIx::Class;

subtype Schema, as 'Object';
coerce Schema, (
    from Str     => via { &from_string },
    from HashRef => via { &from_hashref },
);

=head1 FUNCTIONS

=head2 from_string

 $schema = from_string("$schema_class $dsn");

=cut

sub from_string {
    my $input = $_;

    if($input =~ /([\w:]+)\s(.*)/) {
        my $schema = $1;
        my $dsn    = $2; # "$dsn $username $password";
        eval "require $schema" or confess $@;
        return $schema->connect(split /\s+/, $dsn);
    }
    else {
        confess "cannot load from database";
    }
}

=head2 from_hashref

 $schema = from_hashref({
               schema => $class_name,
               dsn => $dbi_dsn,
               username => $str,
               password => $str,
               %dbi_params,
           });

=cut

sub from_hashref {
    my $args = $_;
    my $schema;

    confess "need schema" unless($schema = delete $args->{'schema'});
    confess "need dsn"    unless($args->{'dsn'});

    eval "require $schema" or confess $@;

    return $schema->connect(
        delete $args->{'dsn'},
        delete $args->{'username'},
        delete $args->{'password'},
        $args,
    );
}

=head1 AUTHOR

See L<Fuse::Template>

=cut

1;
