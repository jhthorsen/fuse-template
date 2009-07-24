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

=cut

use Moose;
use threads;
use threads::shared;

with qw/Fuse::Template::Sys/;

=head1 ATTRIBUTES

=head2 mountpoint

 $path = $self->mountpoint;

Path to where the filesystem should be mounted.

Required.

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

    Fuse::main(
        mountpoint => $self->mountpoint,
        debug      => $self->debug,
        mountopts  => $self->mountopts,
        threaded   => 1,
        %callbacks,
    );

    return 0;
}

=head2 find_file

 $real_path = $self->find_file($virtual_path);

Returns path to the actual template file, from C<$virtual_path>.

=cut

sub find_file {
    my $self  = shift;
    my $vfile = shift;

    # ...

    return "";
}

=head2 log

 $bool = $self->log($level, $format, @args);

=cut

sub log {
    my $self = shift;
    warn "@_";
}

=head1 AUTHOR

Jan Henning Thorsen

=cut

1;
