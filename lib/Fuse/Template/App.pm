package Fuse::Template::App;

=head1 NAME

Fuse::Template::App - Application role for fuse-template

=cut

use Moose::Role;
use Fuse;
use threads;
use threads::shared;

with 'MooseX::Getopt';

MooseX::Getopt::OptionTypeMap->add_option_type_to_map(
    Fuse::Template::Root::RootObject, '=s'
);
MooseX::Getopt::OptionTypeMap->add_option_type_to_map(
    Fuse::Template::Schema::Schema, '=s'
);

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
        exec perldoc => grep { m[ Fuse/Template.pm$ ]x } values %INC;
    }

    for my $method (Fuse::Template::Sys->meta->get_method_list) {
        $callbacks{$method} = sub { $self->$method(@_) };
    }

    $self->log(info => "Starting Fuse mainloop");

    Fuse::main(
        %callbacks,
        mountpoint => $self->mountpoint,
        debug      => $self->debug || 0,
        mountopts  => $self->mountopts || q(),
        threaded   => 0,
    );

    return 0;
}

=head1 AUTHOR

See L<Fuse::Template>.

=cut

1;
