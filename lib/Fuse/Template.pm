package Fuse::Template;

=head1 NAME

Fuse::Template - Mount a template dir

=head1 NOTE

This project is a work in progress - Nothing works just now.

=head1 DESCRIPTION

File system structure:

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

Mount options:

 allow_other

=cut

has mountopts => (
    is => 'ro',
    isa => 'Str',
    default => '',
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

has _templates => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { {} },
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
    my $root  = $self->root;

    $self->log(debug => "Locate file from %s", $vfile);

    if(-e "$root/$vfile.tt") {
        return "$root/$vfile.tt";
    }
    else {
        return "$root/$vfile";
    }
}

=head2 log

 $bool = $self->log($level => $format => @args);

=cut

sub log {
    return unless $_[0]->debug;

    my $self   = shift;
    my $level  = shift;
    my $format = shift;
    my @args;

    for(@_) {
        push @args, defined $_ ? $_ : '__UNDEF__';
    }

    warn sprintf "%s $level $format", scalar(localtime), @args;
}

# around ::Sys::getdir(...);
around getdir => sub {
    my $next  = shift;
    my $self  = shift;
    my @files = $self->$next(@_);

    return map { s/\.tt$//; $_; } @files;
};

# around ::Sys::read(...);
around read => sub {
    my($next, $self, $vfile, $bufsize, $offset) = @_;
    my $file = $self->find_file($vfile);
    my $template;

    # standard file
    unless($file =~ /\.tt$/) {
        return $self->$next($vfile, $bufsize, $offset);
    }

    unless($template = $self->_templates->{$vfile}) {
        $template = $self->_templates->{$vfile} = $self->_template($file);
    }

    return $template;
};

sub _template {
    return "foo";
}

=head1 AUTHOR

Jan Henning Thorsen

=cut

1;
