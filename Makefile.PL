use inc::Module::Install;

name 'String-Comments-Extract';
all_from 'lib/String/Comments/Extract.pm';

build_requires 'Test::More';

auto_install;

WriteAll;

