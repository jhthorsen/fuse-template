package Fuse::Template::TT;

=head1 NAME

Fuse::Template::TT - Read template files

=cut

use Moose;
use Template;

=head1 ATTRIBUTES

=head2 vars

Holds a hash ref with the variables which is available in the template.

=cut

has vars => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { {} },
);

=head2 paths

Holds an array ref with paths to where L<Template::Toolkit> will look
for templates.

=cut

has paths => (
    is => 'ro',
    isa => 'ArrayRef',
    default => sub { [] },
);

has _template => (
    is => 'ro',
    isa => 'Object',
    lazy_build => 1,
    handles => [qw/process error/],
);

sub _build__template {
    return Template->new(
        INCLUDE_PATH => $_[0]->paths,
        EVAL_PERL => 0,
        TEMPLATE_EXTENSION => 'tt',
    );
}

=head1 METHODS

=head2 render

    $text = $self->render($vfile);

Will return the output from a processed template. The C<$vfile> points
to a template relative to one of the L</paths>. It cannot start with "/".

C<$text> will hold the error message if templat toolkit fail to render
the template.

=cut

sub render {
    my $self = shift;
    my $vfile = shift;
    my $text;
    
    $self->process($vfile, $self->vars, \$text);

    return $text ? $text : $self->error;
}

=head2 process

See L<Template>.

=head2 error

See L<Template>.

=head1 AUTHOR

See L<Fuse::Template>.

=cut

1;
