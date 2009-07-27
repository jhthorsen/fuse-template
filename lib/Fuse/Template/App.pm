package Fuse::Template::App;

=head1 NAME

Fuse::Template::App - Application role for fuse-template

=cut

use Moose::Role;
use Fuse;
use threads;
use threads::shared;

with 'MooseX::Getopt';

=head1 ATTRIBUTES

=head2 help

 $bool = $self->help;

=cut

has help => (
    is => 'ro',
    isa => 'Bool',
    documentation => 'This help text',
);

=head2 man

 $bool = $self->man;

=cut

has man => (
    is => 'ro',
    isa => 'Bool',
    documentation => 'Read Fuse::Template manual',
);

=head1 METHODS

=head2 run

 $exit_code = $self->run;

Starts L<Fuse>'s mainloop.

=cut

sub run {
    my $self = shift;
    my %callbacks;

    if($self->help) {
        exit 0;
    }
    elsif($self->man) {
        exec perldoc => map { $INC{$_} } grep { $_ eq 'Fuse/Template.pm' } keys %INC;
    }

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

=head1 AUTHOR

See L<Fuse::Template>.

=cut

1;
