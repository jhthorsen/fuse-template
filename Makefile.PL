use inc::Module::Install;

name q(Fuse-Template);
all_from q(lib/Fuse/Template.pm);

requires q(Class::MOP::Object) => 1.03;
requires q(Fuse) => 0.09;
requires q(Moose) => 1.07;
requires q(MooseX::Getopt) => 0.26;
requires q(MooseX::Types) => 0.21;
requires q(DBIx::Class::Schema::Loader) => 0.07;
requires q(Template) => 2.0;
 
test_requires q(DBD::SQLite) => 1.0;
test_requires q(Test::More) => 0.94;
test_requires q(Test::Pod) => 1.2;
test_requires q(Test::Pod::Coverage) => 1.0;

bugtracker q(http://rt.cpan.org/NoAuth/Bugs.html?Dist=Fuse-Template);
homepage q(http://search.cpan.org/dist/Fuse-Template);
repository q(git://github.com//home/repositories/fuse-template.git);

install_script glob('bin/*');
auto_install;
WriteAll;
