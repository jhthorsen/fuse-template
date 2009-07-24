package Fuse::Template;

=head1 NAME

Fuse::Template - Mount a template dir

=head1 NOTE

This project is a work in progress - Nothing works just now.

=head1 DESCRIPTION

 root/               -> mountpooit/
 root/somefile       -> mountpoint/somefile
 root/foo.tt         -> mountpoint/foo
 root/bar/baz.txt.tt -> mountpoint/bar/baz.txt

C<somefile> is accessible directly at C<mountpoint>. Template files (.tt)
are read and the output is accessible on mountpoint side.

Files in mountpoint are read-only.

=head1 TEMPLATES

Here is an example template:

 root = [% self.root %]
 [% rs = schema.resultset('MyTable') %]
 [% rs = MyTable; # same as schema.resultset(...) %]
 [% WHILE (row = rs.next) # get next row in resultset %]
 col_name = [% row.col_name # retrieve column data %]
 [% END %]

See L<DBIx::Class> for information on how to use the L<schema> object.

=cut

use Moose;
use Fuse::Template::Schema qw/Schema/;
use threads;
use threads::shared;

with qw/Fuse::Template::Sys/;

=head1 ATTRIBUTES

=head2 root

 $object = $self->root;

C<$object> must be stringified to path where templates/files are located.
C<$object> must follow the same API as L<Fuse::Template::Root>.

Can be set in constructor as:

 root => \%constructor_args
 root => $path_to_root

C<%constructor_args> can override defaults, while C<$path_to_root> will
only override C<path> attribute in root-object.

=head2 mountpoint

 $path = $self->mountpoint;

Path to where the filesystem should be mounted.

=cut

has mountpoint => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

=head2 mountopts

 $str = $self->mountopts;

Default: "allow_other".

=cut

has mountopts => (
    is => 'ro',
    isa => 'Str',
    default => 'allow_other',
);

=head2 debug

 $bool = $self->debug;

Enable/disable debug output from L<Fuse>. Default is disabled.

=cut

has debug => (
    is => 'ro',
    isa => 'Bool',
    default => 0,
);

=head2 schema

 $dbic_object = $self->schema;

Can be set in constructor as:

 schema => \%args
 schema => "$dsn $username $password"

See L<Fuse::Template::Schema> for details.

=cut

has schema => (
    is => 'ro',
    isa => Schema,
    coerce => 1,
);

=head1 METHODS

=head2 run

 $exit_code = $self->run;

Starts L<Fuse>'s mainloop.

=cut

sub run {
    my $self = shift;
    my %callbacks;

    for my $method (Fuse::Template::Sys->meta->get_method_list) {
        $callbacks{$method} = sub { $self->$method(@_) };
    }

    $self->log(info => "Starting Fuse mainloop");

    Fuse::main(
        %callbacks,
        mountpoint => $self->mountpoint,
        debug      => $self->debug,
        mountopts  => $self->mountopts,
        threaded   => 1,
    );

    return 0;
}

=head2 find_file

 $real_path = $self->find_file($virtual_path);

Returns path to the file in root path.

=cut

sub find_file {
    my $self  = shift;
    my $vfile = shift;

    $self->log(debug => "Locate file from %s", $vfile);

    return "";
}

=head2 log

 $bool = $self->log($level => $format => @args);

=cut

sub log {
    my $self   = shift;
    my $level  = shift;
    my $format = shift;
    my @args;

    for(@_) {
        push @args, defined $_ ? $_ : '__UNDEF__';
    }

    warn sprintf "%s $level $format", time, @args;
}

=head1 AUTHOR

Jan Henning Thorsen

=cut

1;
