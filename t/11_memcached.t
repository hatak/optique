use strict;
use warnings;
use Test::More;
use Test::Deep;

use Optique::Memcached;
use t::Util;

my $memcached_servers = t::Util::run_memcached();

subtest 'Check methods' => sub {

    can_ok('Optique::Memcached' => 'new');
    can_ok('Optique::Memcached' => 'delete');
    can_ok('Optique::Memcached' => 'flush_all');
    can_ok('Optique::Memcached' => 'get_all');
    can_ok('Optique::Memcached' => 'get');
    can_ok('Optique::Memcached' => 'set');

};

subtest 'Check constructor' => sub {

    subtest 'with no value' => sub {
        my $mc = Optique::Memcached->new();

        isa_ok($mc => 'Optique::Memcached');
        isa_ok($mc->{_memd} => 'Cache::Memcached');
        is_deeply($mc->{_memd}{servers} => [ 'localhost:11211' ]);
    };

    subtest 'with hash values' => sub {
        my $mc = Optique::Memcached->new(servers => [ 'example.com:12345' ]);

        isa_ok($mc => 'Optique::Memcached');
        isa_ok($mc->{_memd} => 'Cache::Memcached');
        is_deeply($mc->{_memd}{servers} => [ 'example.com:12345' ]);
    };

    subtest 'with hashref values' => sub {
        my $mc = Optique::Memcached->new(+{ servers => [ 'example.com:12345' ] });

        isa_ok($mc => 'Optique::Memcached');
        isa_ok($mc->{_memd} => 'Cache::Memcached');
        cmp_deeply($mc->{_memd}{servers} => [ 'example.com:12345' ]);
    };

};

subtest 'Check get/set method' => sub {

    my $mc = Optique::Memcached->new(servers => $memcached_servers);

    $mc->set('num0' => 0);
    $mc->set('num1' => 123);
    $mc->set('num2' => 456);
    $mc->set('num3' => 789);
    $mc->set('str0' => '');
    $mc->set('str1' => 'hoge');
    $mc->set('str2' => 'fuga');
    $mc->set('str3' => 'fizz');
    $mc->set('str4' => 'buzz');

    is($mc->get('num0') => 0);
    is($mc->get('num1') => 123);
    is($mc->get('num2') => 456);
    is($mc->get('num3') => 789);
    is($mc->get('str0') => '');
    is($mc->get('str1') => 'hoge');
    is($mc->get('str2') => 'fuga');
    is($mc->get('str3') => 'fizz');
    is($mc->get('str4') => 'buzz');

    is($mc->get('undefined') => undef);

};

subtest 'Check get_all method' => sub {

    my $mc = Optique::Memcached->new(servers => $memcached_servers);

    my $expected = set(
        { key => 'num0', value => 0, },
        { key => 'num1', value => 123, },
        { key => 'num2', value => 456, },
        { key => 'num3', value => 789, },
        { key => 'str0', value => '', },
        { key => 'str1', value => 'hoge', },
        { key => 'str2', value => 'fuga', },
        { key => 'str3', value => 'fizz', },
        { key => 'str4', value => 'buzz', },
    );
    cmp_deeply($mc->get_all => $expected);

};

subtest 'Check delete method' => sub {

    my $mc = Optique::Memcached->new(servers => $memcached_servers);

    $mc->delete('num1');
    is($mc->get('num1') => undef);

    $mc->delete('str2');
    is($mc->get('str2') => undef);

    my $expected = set(
        { key => 'num0', value => 0, },
        { key => 'num2', value => 456, },
        { key => 'num3', value => 789, },
        { key => 'str0', value => '', },
        { key => 'str1', value => 'hoge', },
        { key => 'str3', value => 'fizz', },
        { key => 'str4', value => 'buzz', },
    );
    cmp_deeply($mc->get_all => $expected);

};

subtest 'Check flush_all method' => sub {

    my $mc = Optique::Memcached->new(servers => $memcached_servers);
    $mc->flush_all();

    is($mc->get('num0') => undef);
    is($mc->get('num1') => undef);
    is($mc->get('num2') => undef);
    is($mc->get('num3') => undef);
    is($mc->get('str0') => undef);
    is($mc->get('str1') => undef);
    is($mc->get('str2') => undef);
    is($mc->get('str3') => undef);
    is($mc->get('str4') => undef);

};

done_testing;
