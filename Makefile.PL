use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Mojolicious::Plugin::RedirectHost',
    AUTHOR              => q{Alex <alexbyk@cpan.org>},
    VERSION_FROM        => 'lib/Mojolicious/Plugin/RedirectHost.pm',
    ABSTRACT_FROM       => 'lib/Mojolicious/Plugin/RedirectHost.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'Mojolicious' => 2
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Mojolicious-Plugin-RedirectHost-*' },
);
