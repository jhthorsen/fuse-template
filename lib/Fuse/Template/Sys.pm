package Fuse::Template::Sys;

=head1 NAME

Fuse::Template::Sys - Moose role for system calls

=head1 DESCRIPTION

This role requires C<find_file()> and C<log()>.

Documentation is mainly copy/paste from L<Fuse>.

It should be possible to use this role in other projects as well.
I might even seperate it out as a standalone distribution some day.

=cut

use Moose::Role;
use Fuse::Template::Root qw/RootObject/;
use Fuse ();
use POSIX ();

requires qw/find_file log/;

=head1 ATTRIBUTES

=head2 root

Holds a L<Fuse::Template::Root> object.

=cut

has root => (
    is => 'ro',
    isa => RootObject,
    coerce => 1,
    documentation => "Location to template files",
    #required => 1,
);

=head1 METHODS

=head2 getattr

 @stat = $self->getattr($virtual_path);

Return value is the same format as from C<stat($file)>.

=cut

sub getattr {
    my $self  = shift;
    my $vfile = shift;
    my $file  = $self->find_file($vfile);
    my $root  = $self->root;

    $self->log(debug => "getattr(%s)", $file);

    return -&POSIX::ENOENT unless($file); # such file or directory

    if(length $vfile <= 1) {
        return (
            0,                #  0 device number
            0,                #  1 inode number
            (0040 << 9) + $root->mode, #  2 file mode 
            1,                #  3 number of hard links
            $root->uid,       #  4 user id
            $root->gid,       #  5 group id
            0,                #  6 device indentifier
            4096,             #  7 size
            $root->atime,     #  8 last acess time
            $root->mtime,     #  9 last modified time
            $root->ctime,     # 10 last change time
            $root->block_size,# 11 block size
            0,                # 12 blocks
        );
    }
    else {
        my @stat = lstat $file;
        return -$! unless @stat;
        return @stat;
    }
}

=head2 readlink

 $bool = $self->readlink($virtual_path); 

This is called when dereferencing symbolic links, to learn the target.

=cut

sub readlink {
    my $self  = shift;
    my $vfile = shift;
    my $file  = $self->find_file($vfile);

    $self->log(debug => "readlink(%s)", $file);

    return 0 unless($file); # such file or directory
    return readlink $file;
}

=head2 getdir

 @files = $self->getdir($virtual_path);

Returns a list of filenames from the virtual dir.

This is used to obtain directory listings. Its opendir(), readdir(),
filldir() and closedir() all in one call.

=cut

sub getdir {
    my $self = shift;
    my $vdir = shift;
    my $dir  = $self->find_file($vdir);
    my($DH, @files);

    $self->log(debug => "getdir(%s)", $dir);

    opendir($DH, $dir) or return -&POSIX::ENOENT;
    @files = readdir $DH;

    return @files, 0;
}

=head2 mknod

 $errno = $self->mknod($virtual_path);

This method will always return C<-&POSIX::EROFS>, since write support is not
implemented.

This function is called for all non-directory, non-symlink nodes, not
just devices.

=cut

sub mknod {
    my $self = shift;
    $self->log(error => "mknod => ro");
    return -&POSIX::EROFS; # cannot write
}

=head2 mkdir

 $errno = $self->mkdir($virtual_path, $mode);

This method will always return C<-&POSIX::EROFS>, since write support is not
implemented.

Called to create a directory.

=cut

sub mkdir {
    my $self = shift;
    $self->log(error => "mkdir => ro");
    return -&POSIX::EROFS; # cannot write
}

=head2 unlink

 $errno = $self->unlink($virtual_path);

This method will always return C<-&POSIX::EROFS>, since write support is not
implemented.

Called to remove a file, device, or symlink.

=cut

sub unlink {
    my $self = shift;
    $self->log(error => "unlink => ro");
    return -&POSIX::EROFS; # cannot write
}

=head2 rmdir

 $errno = $self->rmdir($virtual_path);

This method will always return C<-&POSIX::EROFS>, since write support is not
implemented.

Called to remove a directory.

=cut

sub rmdir {
    my $self = shift;
    $self->log(error => "rmdir => ro");
    return -&POSIX::EROFS; # cannot write
}

=head2 symlink

 $errno = $self->symlink($virtual_path, $symlink_name);

This method will always return C<-&POSIX::EROFS>, since write support is not
implemented.

Called to create a symbolic link.

=cut

sub symlink {
    my $self = shift;
    $self->log(error => "symlink => ro");
    return -&POSIX::EROFS; # cannot write
}

=head2 rename

 $errno = $self->rmdir($old_virtual_path, $new_virtual_path);

This method will always return C<-&POSIX::EROFS>, since write support is not
implemented.

Called to rename a file, and/or move a file from one directory to another.

=cut

sub rename {
    my $self = shift;
    $self->log(error => "rename => ro");
    return -&POSIX::EROFS; # cannot write
}

=head2 link

 $errno = $self->link($virtual_path, $hardlink_name);

This method will always return C<-&POSIX::EROFS>, since write support is not
implemented.

Called to create hard links.

=cut

sub link {
    my $self = shift;
    $self->log(error => "link => ro");
    return -&POSIX::EROFS; # cannot write
}

=head2 chmod

 $errno = $self->chmod($virtual_path, $mode);

This method will always return C<-&POSIX::EROFS>, since write support is not
implemented.

Called to change permissions on a file/directory/device/symlink.

=cut

sub chmod {
    my $self = shift;
    $self->log(error => "chmod => ro");
    return -&POSIX::EROFS; # cannot write
}

=head2 chown

 $errno = $self->chown($virtual_path, $uid, $gid);

This method will always return C<-&POSIX::EROFS>, since write support is not
implemented.

Called to change ownership of a file/directory/device/symlink.

=cut

sub chown {
    my $self = shift;
    $self->log(error => "chown => ro");
    return -&POSIX::EROFS; # cannot write
}

=head2 truncate

 $errno = $self->truncate($virtual_path, $offset);

This method will always return C<-&POSIX::EROFS>, since write support is not
implemented. 

Called to truncate a file, at the given offset.

=cut

sub truncate {
    my $self = shift;
    $self->log(error => "truncate => ro");
    return -&POSIX::EROFS; # cannot write
}

=head2 utime

 $errno = $self->utime($virtual_path, $actime, $modtime);

This method will always return C<-&POSIX::EROFS>, since write support is not
implemented.

Called to change access/modification times for a
file/directory/device/symlink.

=cut

sub utime {
    my $self = shift;
    $self->log(error => "utime => ro");
    return -&POSIX::EROFS; # cannot write
}

=head2 open

 $errno = $self->open($virtual_path, $mode);

Called to open a file.

=cut

sub open {
    my $self  = shift;
    my $vfile = shift;
    my $mode  = shift;
    my $file  = $self->find_file($vfile);

    $self->log(debug => 'open(%s, %s)', $file, $mode);

    return -$! unless(sysopen my $FH, $file, $mode);
    return 0;
}

=head2 read

 $ret = $self->read($virtual_path, $buf_size, $offset);

C<$ret> can be either C<$errno> or data read.

Called in an attempt to fetch a portion of the file.

=cut

sub read {
    my $self    = shift;
    my $vfile   = shift;
    my $bufsize = shift;
    my $offset  = shift;
    my $file    = $self->find_file($vfile);
    my $size    = -s $file;
    my($FH, $buf);

    $self->log(debug => 'read(%s, %i, %i)', $file, $bufsize, $offset);

    # check for file existence
    return -&POSIX::ENOENT() unless(defined $size);

    # open and read file
    sysopen $FH, $file, &POSIX::O_RDONLY   or return -&POSIX::ENOSYS;
    sysseek $FH, $offset, &POSIX::SEEK_SET or return -&POSIX::ENOSYS;
    sysread $FH, $buf, $bufsize    or return -&POSIX::ENOSYS;

    return $buf;
}

=head2 write

 $ret = $self->write($virtual_path, $buf_size, $offset);

C<$ret> can be either C<$errno> or length of data read.

This method will always return C<-&POSIX::EROFS>, since write support is not
implemented.

Called in an attempt to write (or overwrite) a portion of the file.

=cut

# Be prepared because $buffer could contain random binary data with
# NULLs and all sorts of other wonderful stuff.
sub write {
    my $self = shift;
    $self->log(error => 'write => ro');
    return -&POSIX::EROFS;
}

=head2 statfs

 @ret = $self->statfs;

C<@ret> can be on of:

 ($namelen, $files, $files_free, $blocks, $blocks_avail, $blocksize)
 -ENOANO()

=cut

sub statfs {
    my $self  = shift;
    my $total = {
        blocks => 0, # total blocks
        bfree  => 0, # total free blocks
        files  => 0, # total inodes
        ffree  => 0, # total free inodes
    };

    $self->log(debug => "statfs()");

    return(
        255,
        $total->{'blocks'},
        $total->{'bfree'},
        $total->{'files'},
        $total->{'ffree'},
        $self->root->block_size,
    );
}

=head2 flush

 $errno = $self->flush($virtual_path);

Called to synchronise any cached data. This is called before the file
is closed. It may be called multiple times before a file is closed.

=cut

sub flush {
    my $self  = shift;
    my $vfile = shift;
    $self->log(debug => 'flush...');
    return 0;
}

=head2 release

 $errno = $self->release($virtual_path, $flags);

Called to indicate that there are no more references to the file.
Called once for every file with the same pathname and flags as were
passed to open.

=cut

sub release {
    my $self  = shift;
    my $vfile = shift;
    my $flags = shift;
    $self->log(debug => 'release...');
    return 0;
}

=head2 fsync

 $int = $self->fsync($virtual_path, $flags);

Called to synchronise the file's contents. If flags is non-zero, only
synchronise the user data. Otherwise synchronise the user and meta data.

=cut

sub fsync {
    my $self  = shift;
    my $vfile = shift;
    my $flags = shift;
    $self->log(debug => 'fsync...');
    return 1;
}

=head2 setxattr

 $errno = $self->setxattr(
              $virtual_path, $attr_name, $attr_value, $flags
          );

Called to set the value of the named extended attribute.

Will always return C<-EOPNOTSUPP()> since write is not supported.

=cut

sub setxattr {
    my $self  = shift;
    my $vfile = shift;
    my $name  = shift;
    my $value = shift;
    my $flags = shift; # OR-ing of XATTR_CREATE and XATTR_REPLACE

    $self->log(debug => 'setxattr(%s, %s, %s, %s)',
        $vfile, $name, $value, $flags,
    );

    return -&POSIX::EOPNOTSUPP();
}

=head2 getxattr

 $ret = $self->getxattr($virtual_path, $attr_name);

Called to get the value of the named extended attribute.

=cut

# If flags is set to XATTR_CREATE and the extended attribute already exists,
# this should fail with -EEXIST(). If flags is set to XATTR_REPLACE and the
# extended attribute doesn't exist, this should fail with -ENOATTR().
sub getxattr {
    my $self  = shift;
    my $vfile = shift;
    my $name  = shift;
    my $value;

    $self->log(debug => 'getxattr(%s, %s)', $vfile, $name);
 
    return $value if($value);
    return 0; # no such name
}

=head2 listxattr

 @list = $self->listxattr;

Called to get the value of the named extended attribute.

=cut

sub listxattr {
    my $self = shift;
    $self->log(debug => 'listxattr...');
    return 0;
}

=head2 removexattr

 $errno = $self->removexattr($virtual_path, $attr_name);

This method will always return C<-&POSIX::EROFS>, since write support is not
implemented.

=cut

sub removexattr {
    my $self  = shift;
    my $vfile = shift;
    my $name  = shift;
    $self->log(debug => 'removexattr => ro');
    return -&POSIX::EROFS; # cannot write
}

=head1 AUTHOR

See L<Fuse::Template>

=cut

1;
