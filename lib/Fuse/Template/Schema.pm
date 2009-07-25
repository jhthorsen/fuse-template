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

BEGIN {
    # required for extends + MooseX::Types to work properly
    use Moose;
    extends qw/DBIx::Class::Schema::Loader/;
}

use MooseX::Types -declare => [qw/Schema/];
use MooseX::Types::Moose qw(:all);
use DBIx::Class;

subtype Schema, as Object;
coerce Schema, (
    from Str,     via { &from_string },
    from HashRef, via { &from_hashref },
);

=head1 FUNCTIONS

=head2 from_string

 $schema = from_string("$schema_class $dsn");
 $schema = from_string("$schema_class $dsn $username $password");
 $schema = from_string("$dsn ...");

=cut

sub from_string {
    my $input = $_;

    if($input =~ /([\w:]+)\s(.*)/) {
        my $class = $1;
        my $dsn   = $2; # "$dsn $username $password";
        eval "require $class" or confess $@;
        return $class->connect(split /\s+/, $dsn);
    }
    elsif($input) {
        return __PACKAGE__->connect(split /\s+/, $input);
    }
    else {
        confess "invalid arguments";
   }
}

=head2 from_hashref

 $schema = from_hashref({
               schema => $class_name, # optional
               dsn => $dbi_dsn,
               username => $str,
               password => $str,
               %dbi_params, # optional
           });

=cut

sub from_hashref {
    my $args   = $_;
    my $schema = delete $args->{'schema'};

    confess "'dsn' is required" unless($args->{'dsn'});

    $schema ||= __PACKAGE__;

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
