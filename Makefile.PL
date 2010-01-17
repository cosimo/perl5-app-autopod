use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'App::autopod',
    AUTHOR              => 'Cosimo Streppone <cosimo@cpan.org>',
    VERSION_FROM        => 'lib/App/autopod.pm',
    ABSTRACT_FROM       => 'lib/App/autopod.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    META_MERGE => {
        resources => {
            repository => 'git://github.com/cosimo/perl5-app-autopod.git',
            bugtracker => 'mailto:bug-app-autopod@rt.cpan.org',
            license    => 'http://dev.perl.org/licenses/',
        },
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'App-autopod-*' },
);

