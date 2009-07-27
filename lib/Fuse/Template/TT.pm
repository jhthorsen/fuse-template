package Fuse::Template::TT;

=head1 NAME

Fuse::Template::TT - Read template files

=cut

use Moose;
use Template;

=head1 ATTRIBUTES

=head2 vars

 $hash_ref = $self->vars;

=cut

has vars => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { {} },
);

=head2 paths

 $array_ref = $self->paths;

=cut

has paths => (
    is => 'ro',
    isa => 'ArrayRef',
    default => sub { [] },
);

has _template => (
    is => 'ro',
    isa => 'Object',
    required => 1,
    handles => [qw/process error/],
);

=head1 METHODS

=head2 BUILDARGS

 $hash_ref = $self->BUILDARGS(%args);

=cut

sub BUILDARGS {
    my $self = shift;
    my $args = ref $_[0] eq 'HASH' ? $_[0] : {@_};

    $args->{'_template'} = Template->new(
        INCLUDE_PATH => $args->{'include_path'} || $args->{'paths'},
        EVAL_PERL => $args->{'eval_perl'} || 0,
        TEMPLATE_EXTENSION => $args->{'template_exension'} || 'tt',
    );

    return $args;
}

=head2 render

 $output = $self->render($virtual_file);

=cut

sub render {
    my $self  = shift;
    my $vfile = shift;
    my $output;
    
    $self->process($vfile, $self->vars, \$output);

    return $output ? $output : $self->error;
}

=head2 process

See L<Template>.

=head2 error

See L<Template>.

=head1 AUTHOR

See L<Fuse::Template>.

=cut

1;
