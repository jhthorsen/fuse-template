package Fuse::Template;

=head1 NAME

Fuse::Template - Mount a directory with templates.

=head1 VERSION

0.01_002

=head1 USAGE

C<sudo> might be optional.

=head2 MOUNT

Example SQLite:

 $ sudo fuse-template
   --root /path/to/templates \
   --mountpoint /path/to/mountpoint \
   --schema dbi:SQLite:path/to/db \
   ;

Example MySQL:

 $ sudo fuse-template
   --root /path/to/templates \
   --mountpoint /path/to/mountpoint \
   --schema "dbi:mysql:database=MyDB;host=127.1;port=3006 user pass" \
   ;

See L<DBI> for possible C<--schema> formats.

=head2 UNMOUNT

This needs to be done manually for now. (Patches are welcome!)

 sudo umount /path/to/mountpoint;

=head1 DESCRIPTION

The idea with this project is to auto-maintain password files, and other
plain text files for different systems, with data from a database.

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

See L<DBIx::Class> for information on how to use the L<schema> object, and
L<DBIx::Class::Resultset> on how to select data and more...

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

=head1 INSTALLATION

On ubuntu:

    $ sudo aptitude install libfuse-perl
    $ wget -q http://xrl.us/cpanm | perl - --sudo Fuse::Template

See L<App::cpanminus> if you are curious about the "wget" command.

=cut

use Moose;
use Fuse::Template::Schema qw/Schema/;
use Fuse::Template::TT;

with qw/Fuse::Template::Sys/;

our $VERSION = "0.01_002";

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
    lazy_build => 1,
    documentation => 'Schema name or dsn',
);

sub _build_schema {
    confess "Cannot build schema without information!";
}

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
    my $root  = $self->root->path;
    my $file;

    $root  =~ s,/+$,,;
    $vfile =~ s,^/+,,;

    if(-e "$root/$vfile.tt") {
        $file = "$root/$vfile.tt";
    }
    elsif(-e "$root/$vfile") {
        $file = "$root/$vfile";
    }

    $self->log(debug => "%s = %s + find_file(%s)", $file, $root, $vfile);

    return $file;
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

    warn sprintf "$level - $format\n", @args;
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
        $vfile =~ s,^/,,;

        if($self->has_schema) {
            my $vars = $self->_template->vars;
            my $schema = $self->schema;
            $vars->{'schema'} = $schema;
            $vars->{$_} = $schema->resultset($_) for($schema->sources);
        }

        my $output = $self->render("$vfile.tt");
        return substr $output, $offset, $bufsize;
    }
    else {
        return $self->$next($vfile, $bufsize, $offset);
    }
};

=head1 AUTHOR

Jan Henning Thorsen

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
