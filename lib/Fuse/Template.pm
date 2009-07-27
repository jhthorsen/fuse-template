package Fuse::Template;

=head1 NAME

Fuse::Template - Mount a directory with templates.

=head1 DESCRIPTION

The idea with this project is to auto-maintain password files, and other
plain text files for different systems, with data from a database.

Got issues with installation? See C<INSTALL> for details and list
of prerequisite.

See C<examples/> in this distribution for templates.

Example file system structure:

 root/               -> mountpooit/
 root/somefile       -> mountpoint/somefile
 root/foo.tt         -> mountpoint/foo
 root/bar/baz.txt.tt -> mountpoint/bar/baz.txt

C<somefile> is accessible directly at C<mountpoint>. Template files (.tt)
are parsed and the output is accessible on mountpoint side. This is done
using L<Template::Toolkit>.

Files in mountpoint are read-only for now.

=head1 TEMPLATES

Here is an example template:

 root = [% self.root %]
 [% rs = schema.resultset('MyTable') %]
 [% rs = MyTable; # same as schema.resultset(...) %]
 [% WHILE (row = rs.next) # get next row in resultset %]
 col_name = [% row.col_name # retrieve column data %]
 [% END %]

See L<DBIx::Class> for information on how to use the L<schema> object.

Available variables:

 root
 mountpoint
 mountopts
 self # this object
 schema # DBIx::Class object
 + all resultsetset/tables

Resultset use this naming convention to convert tablenames:

    Table Name  | Moniker Name
    ---------------------------
    luser       | Luser
    luser_group | LuserGroup
    luser-opts  | LuserOpts

See L<DBIx::Class::Schema::Loader/moniker_map> for details

=cut

use Moose;
use Fuse::Template::Schema qw/Schema/;
use Fuse::Template::TT;

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
    documentation => 'Path to mount point',
    #required => 1,
);

=head2 mountopts

 $str = $self->mountopts;

Example mount option: "allow_other"

=cut

has mountopts => (
    is => 'ro',
    isa => 'Str',
    documentation => 'Mount options. Example: "allow_other"',
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
    documentation => 'Schema name or dsn. --schema help for details',
);

=head2 debug

 $bool = $self->debug;

Enable/disable debug output from L<Fuse>. Default is disabled.

=cut

has debug => (
    is => 'ro',
    isa => 'Bool',
    default => 0,
    documentation => 'Enable/disable debug output',
);

has _template => (
    is => 'ro',
    isa => 'Object',
    handles => [qw/render/],
    lazy_build => 1,
);

sub _build__template {
    my $self = shift;
    
    return Fuse::Template::TT->new(
        paths => [$self->root->path],
        vars => {
            root => $self->root->path,
            mountpoint => $self->mountpoint,
            mountopts => $self->mountopts,
            self => $self,
            schema => $self->schema,
            map { $_, $self->schema->resultset($_) } $self->schema->sources,
        },
    );
}

=head1 METHODS

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

    # standard file
    if($file =~ /\.tt$/) {
        my $output = $self->render("$vfile.tt");
        return substr $output, $offset, $bufsize;
    }
    else {
        return $self->$next($vfile, $bufsize, $offset);
    }
};

=head1 AUTHOR

Jan Henning Thorsen

=cut

1;
