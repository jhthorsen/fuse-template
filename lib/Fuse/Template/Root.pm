package Fuse::Template::Root;

=head1 NAME

Fuse::Template::Root

=head1 SYNOPSIS

 # will import RootObject typeconstraint
 use Fuse::Template::Root qw/RootObject/;
 has foo => ( isa => RootObject, coerce => 1 );
 ...

=cut

use Moose;
use MooseX::Types -declare => [qw/RootObject/];
use overload q("") => sub { shift->path }, fallback => 1;

subtype RootObject, as "Object";
coerce RootObject, (
    from Str     => via { Fuse::Template::Root->new(path => $_) },
    from HashRef => via { Fuse::Template::Root->new($_) },
);

=head1 ATTIBUTES

=head2 path

 $path = $self->path;

=cut

has path => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

=head2 mode

 $int = $self->mode;

=cut

has mode => (
    is => 'ro',
    isa => 'Int',
    default => 0775,
);

around mode => sub {
    my $next = shift;
    my $self = shift;

    if(@_) {
        return $self->$next((0040 << 9) + $_[0]);
    }
    else {
        return $self->$next;
    }
};

=head2 uid

 $int = $self->uid;

=cut

has uid => (
    is => 'ro',
    isa => 'Int',
    default => 0,
);

=head2 gid

 $int = $self->gid;

=cut

has gid => (
    is => 'ro',
    isa => 'Int',
    default => 0,
);

=head2 ctime

 $int = $self->ctime;

=cut

has ctime => (
    is => 'ro',
    isa => 'Int',
    default => time,
);

=head2 mtime

 $int = $self->mtime;

=cut

has mtime => (
    is => 'ro',
    isa => 'Int',
    default => time,
);

=head2 atime

 $int = $self->atime;

=cut

has atime => (
    is => 'ro',
    isa => 'Int',
    default => time,
);

=head2 block_size

 $int = $self->block_size;

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
