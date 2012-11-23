use strict;
use warnings;
use Test::More;

subtest 'Compile test for all modules' => sub {

    use_ok $_ for qw(Optique);
    use_ok $_ for qw(Optique::Memcached);
    use_ok $_ for qw(Optique::Redis);

};

done_testing;
