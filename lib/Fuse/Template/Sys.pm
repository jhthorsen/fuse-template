package Fuse::Template::Sys;

=head1 NAME

Fuse::Template::Sys - Moose role for system calls

=head1 DESCRIPTION

This role requires C<find_file()> and C<log()>.

Documentation is mainly copy/paste from L<Fuse>.

=cut

use Fuse ':all';
use Moose::Role;
use Fuse::Template::Root qw/RootObject/;
use Fcntl qw(S_ISBLK S_ISCHR S_ISFIFO SEEK_SET);

require 'syscall.ph'; # for SYS_mknod and SYS_lchown

requires qw/find_file log/;

=head1 ATTRIBUTES

=head2 root

 $root_obj = $self->root;

Required.

=cut

has root => (
    is => 'ro',
    isa => RootObject,
    coerce => 1,
    required => 1,
);

=head2 getattr

 @stat = $self->getattr($virtual_path);

Return value is the same format as from C<stat($file)>.

=cut

sub getattr {
    my $self  = shift;
    my $vfile = shift;
    my $file  = $self->find_file($vfile);
    my $root  = $self->root;
    my @stat;

    $self->log(info => "Getattr %s", $vfile);

    if($file eq $root->path) {
        @stat = (
            0,                # device number
            0,                # inode number
            $root->mode,      # file mode 
            1,                # number of hard links
            $root->uid,       # user id
            $root->gid,       # group id
            0,                # device indentifier
            4096,             # size
            $root->atime,     # last acess time
            $root->mtime,     # last modified time
            $root->ctime,     # last change time
            $root->block_size,# block size
            0,                # blocks
        );
    }
    else {
        @stat = lstat $file;
    }

    return -$! unless @stat;
    return @stat;
}

=head2 readlink

 $bool = $self->readlink($virtual_path); 

This is called when dereferencing symbolic links, to learn the target.

=cut

sub readlink {
    my $self  = shift;
    my $vfile = shift;
    my $file  = $self->find_file($vfile);

    $self->log(info => "Readlink $vfile");

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

    $self->log(info => "Getdir $vdir");

    opendir($DH, $dir) or return -ENOENT();
    @files = readdir $DH;

    return @files, 0;
}

=head2 mknod

 $errno = $self->mknod($virtual_path);

This method will always return C<-EROFS()>, since write support is not
implemented.

This function is called for all non-directory, non-symlink nodes, not
just devices.

=cut

sub mknod {
    my $self = shift;
    return -EROFS(); # cannot write
}

=head2 mkdir

 $errno = $self->mkdir($virtual_path, $mode);

This method will always return C<-EROFS()>, since write support is not
implemented.

Called to create a directory.

=cut

sub mkdir {
    my $self = shift;
    return -EROFS(); # cannot write
}

=head2 unlink

 $errno = $self->unlink($virtual_path);

This method will always return C<-EROFS()>, since write support is not
implemented.

Called to remove a file, device, or symlink.

=cut

sub unlink {
    my $self = shift;
    return -EROFS(); # cannot write
}

=head2 rmdir

 $errno = $self->rmdir($virtual_path);

This method will always return C<-EROFS()>, since write support is not
implemented.

Called to remove a directory.

=cut

sub rmdir {
    my $self = shift;
    return -EROFS(); # cannot write
}

=head2 symlink

 $errno = $self->symlink($virtual_path, $symlink_name);

This method will always return C<-EROFS()>, since write support is not
implemented.

Called to create a symbolic link.

=cut

sub symlink {
    my $self = shift;
    return -EROFS(); # cannot write
}

=head2 rename

 $errno = $self->rmdir($old_virtual_path, $new_virtual_path);

This method will always return C<-EROFS()>, since write support is not
implemented.

Called to rename a file, and/or move a file from one directory to another.

=cut

sub rename {
    my $self = shift;
    return -EROFS(); # cannot write
}

=head2 link

 $errno = $self->link($virtual_path, $hardlink_name);

This method will always return C<-EROFS()>, since write support is not
implemented.

Called to create hard links.

=cut

sub link {
    my $self = shift;
    return -EROFS(); # cannot write
}

=head2 chmod

 $errno = $self->chmod($virtual_path, $mode);

This method will always return C<-EROFS()>, since write support is not
implemented.

Called to change permissions on a file/directory/device/symlink.

=cut

sub chmod {
    my $self = shift;
    return -EROFS(); # cannot write
}

=head2 chown

 $errno = $self->chown($virtual_path, $uid, $gid);

This method will always return C<-EROFS()>, since write support is not
implemented.

Called to change ownership of a file/directory/device/symlink.

=cut

sub chown {
    my $self = shift;
    return -EROFS(); # cannot write
}

=head2 truncate

 $errno = $self->truncate($virtual_path, $offset);

This method will always return C<-EROFS()>, since write support is not
implemented. 

Called to truncate a file, at the given offset.

=cut

sub truncate {
    my $self = shift;
    return -EROFS(); # cannot write
}

=head2 utime

 $errno = $self->utime($virtual_path, $actime, $modtime);

This method will always return C<-EROFS()>, since write support is not
implemented.

Called to change access/modification times for a
file/directory/device/symlink.

=cut

sub utime {
    my $self = shift;
    return -EROFS(); # cannot write
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

    $self->log(info => "open($vfile)");

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
    my($FH, $read);

    $self->log(info => "Read $vfile");

    # check for file existence
    return -ENOENT() unless(defined $size);

    # open and read file
    CORE::open $FH, $file             or return -ENOSYS();
    CORE::seek $FH, $offset, SEEK_SET or return -ENOSYS();
    CORE::read $FH, $read, $bufsize   or return -ENOSYS();

    return $read;
}

=head2 write

 $ret = $self->write($virtual_path, $buf_size, $offset);

C<$ret> can be either C<$errno> or length of data read.

This method will always return C<-EROFS()>, since write support is not
implemented.

Called in an attempt to write (or overwrite) a portion of the file.

=cut

# Be prepared because $buffer could contain random binary data with
# NULLs and all sorts of other wonderful stuff.
sub write {
    my $self = shift;
    return -EROFS();
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

    $self->log(debug => "setxattr $vfile");

    return -EOPNOTSUPP();
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
 
    return $value if($value);
    return 0; # no such name
}

=head2 listxattr

 @list = $self->listxattr;

Called to get the value of the named extended attribute.

=cut

sub listxattr {
    my $self = shift;
    return 0;
}

=head2 removexattr

 $errno = $self->removexattr($virtual_path, $attr_name);

This method will always return C<-EROFS()>, since write support is not
implemented.

=cut

sub removexattr {
    my $self  = shift;
    my $vfile = shift;
    my $name  = shift;
    return -EROFS(); # cannot write
}

=head1 AUTHOR

See L<Fuse::Template>

=cut

1;
