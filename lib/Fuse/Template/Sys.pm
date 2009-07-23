package Fuse::Template::Sys;

=head1 NAME

Fuse::Template::Sys - Moose role for system calls

=head1 DESCRIPTION

This role requires C<find_file()>.

=cut

use Moose::Role;
use threads;
use threads::shared;

require 'syscall.ph'; # for SYS_mknod and SYS_lchown

requires qw/find_file log/;

=head1 ATTRIBUTES

=head2 root

 $root_obj = $self->root;

Required.

=cut

has root => (
    is => 'ro',
    isa => 'Object',
    required => 1,
);

=head2 getattr

 @stat = $self->getattr($virtual_file);

=cut

sub getattr {
    my $self  = shift;
    my $vfile = shift;
    my $file  = $self->find_file($vfile);
    my $root  = $self->root;
    my @stat;

    $self->log(info => "Getattr %s", $vfile);

    if($file eq $self->root->path) {
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
            1024,             # block size
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

 $bool = $self->readlink($vfile); 

=cut

sub readlink {
    my $self  = shift;
    my $vfile = shift;
    my $file  = $self->find_file($vfile);

    $self->log(info => "Readlink $vfile");

    return readlink $file;
}

=head2 getdir

 @files = $self->getdir($virtual_dir);

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

=cut

sub mknod {
    my $self = shift;
}

=head2 mkdir

=cut

sub mkdir {
    my $self = shift;
}

=head2 unlink

=cut

sub unlink {
    my $self = shift;
}

=head2 rmdir

=cut

sub rmdir {
    my $self = shift;
}

=head2 symlink

=cut

sub symlink {
    my $self = shift;
}

=head2 rename

=cut

sub rename {
    my $self = shift;
}

=head2 link

=cut

sub link {
    my $self = shift;
}

=head2 chmod

=cut

sub chmod {
    my $self = shift;
}

=head2 chown

=cut

sub chown {
    my $self = shift;
}

=head2 truncate

=cut

sub truncate {
    my $self = shift;
}

=head2 utime

=cut

sub utime {
    my $self = shift;
}

=head2 open

=cut

sub open {
    my $self = shift;
}

=head2 read

=cut

sub read {
    my $self = shift;
}

=head2 write

=cut

sub write {
    my $self = shift;
}

=head2 statfs

=cut

sub statfs {
    my $self = shift;
}

=head1 AUTHOR

Jan Henning Thorsen

=cut

1;
