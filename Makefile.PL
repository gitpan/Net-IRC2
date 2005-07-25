use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Net::IRC2',
    AUTHOR              => 'Karl Y. Pradene <knotty@cpan.org>',
    VERSION_FROM        => 'lib/Net/IRC2.pm',
    ABSTRACT_FROM       => 'lib/Net/IRC2.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Net-IRC2-*' },
);
