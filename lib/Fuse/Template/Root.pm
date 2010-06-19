package Fuse::Template::Root;

=head1 NAME

Fuse::Template::Root

=head1 SYNOPSIS

    package Class;
    # will import RootObject typeconstraint
    use Fuse::Template::Root qw/RootObject/;
    has foo => ( isa => RootObject, coerce => 1 );
    ...

    package main;

    # same result:
    my $obj = Class->new( foo => { path => $some_root } );
    my $obj = Class->new( foo => $some_root );
    my $obj = Class->new(
                  foo => Fuse::Template::Root->new({
                      path => $some_root
                  }),
              );

=head1 DESCRIPTION

The C<RootObject> can coerce either Str and HashRef into a
L<Fuse::Template::Root> object. The HashRef will be used as object
constructor, while the Str will be set as L</path> attribute.

=cut

use Moose;
use MooseX::Types -declare => [qw/RootObject/];
use MooseX::Types::Moose qw(:all);
use overload q("") => sub { shift->path }, fallback => 1;

subtype RootObject, as Object;
coerce RootObject, (
    from Str,     via { Fuse::Template::Root->new(path => $_) },
    from HashRef, via { Fuse::Template::Root->new($_) },
);

=head1 ATTRIBUTES

=head2 path

Holds a string representing the path to where the template files
exist. This attribute is required.

=cut

has path => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

=head2 mode

Holds the file mode for the target mount directory. Default value
is C<0775>. (octal value)

=cut

has mode => (
    is => 'ro',
    isa => 'Int',
    default => 0775,
);

around mode => sub {
    my $next = shift;
    my $self = shift;

    return @_ ? $self->$next((0040 << 9) + $_[0]) : $self->$next;
};

=head2 uid

The user id of who owns the target mount path. Defaults to the
C<$REAL_USER_ID>

=cut

has uid => (
    is => 'ro',
    isa => 'Int',
    default => $<,
);

=head2 gid

The group id of who owns the target mount path. Defaults to
the first integer from C<$REAL_GROUP_ID>.

=cut

has gid => (
    is => 'ro',
    isa => 'Int',
    default => sub { $( =~ /(\d+)/ },
);

=head2 ctime

Last change time of the target mount path. Defaults to
C<time> when the object got created.

=cut

has ctime => (
    is => 'ro',
    isa => 'Int',
    default => time,
);

=head2 mtime

Last modify time of the target mount path. Defaults to
C<time> when the object got created.

=cut

has mtime => (
    is => 'ro',
    isa => 'Int',
    default => time,
);

=head2 atime

Last access time of the target mount path. Defaults to
C<time> when the object got created.

=cut

has atime => (
    is => 'ro',
    isa => 'Int',
    default => time,
);

=head2 block_size

Preferred block size for file system I/O. Defaults to 1024.
(The default value might change)

=cut

has block_size => (
    is => 'ro',
    isa => 'Int',
    default => 1024,
);

=head1 AUTHOR

See L<Fuse::Template>

=cut

1;
