package Fuse::Template;

=head1 NAME

Fuse::Template - Mount a template dir

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

use Moose;
use threads;
use threads::shared;

require 'syscall.ph'; # for SYS_mknod and SYS_lchown

with qw/Fuse::Template::Sys/;

=head1 ATTRIBUTES

=head2 debug

 $bool = $self->debug;

=cut

has debug => (
    is => 'ro',
    isa => 'Bool',
    default => 0,
);

=head2 mountpoint

 $path = $self->mountpoint;

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

=head1 METHODS

=head2 run

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
