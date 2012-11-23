use strict;
use warnings;
use Test::More;
use Test::Deep;

use Optique::Redis;
use t::Util;

my ($redis_type, $redis_server) = t::Util::run_redis();

subtest 'Check methods' => sub {

    can_ok('Optique::Redis' => 'new');
    can_ok('Optique::Redis' => 'delete');
    can_ok('Optique::Redis' => 'flush_all');
    can_ok('Optique::Redis' => 'get_all');
    can_ok('Optique::Redis' => 'get');
    can_ok('Optique::Redis' => 'set');

};

subtest 'Check constructor' => sub {

    subtest 'with no value' => sub {
        my $redis = Optique::Redis->new();

        isa_ok($redis => 'Optique::Redis');
        isa_ok($redis->{_redis} => 'Redis');
        is($redis->{_redis}{server} => 'localhost:6379');
    };

};

subtest 'Check get/set method' => sub {

    my $redis = Optique::Redis->new($redis_type => $redis_server);

    $redis->set('num0' => 0);
    $redis->set('num1' => 123);
    $redis->set('num2' => 456);
    $redis->set('num3' => 789);
    $redis->set('str0' => '');
    $redis->set('str1' => 'hoge');
    $redis->set('str2' => 'fuga');
    $redis->set('str3' => 'fizz');
    $redis->set('str4' => 'buzz');

    is($redis->get('num0') => 0);
    is($redis->get('num1') => 123);
    is($redis->get('num2') => 456);
    is($redis->get('num3') => 789);
    is($redis->get('str0') => '');
    is($redis->get('str1') => 'hoge');
    is($redis->get('str2') => 'fuga');
    is($redis->get('str3') => 'fizz');
    is($redis->get('str4') => 'buzz');

    is($redis->get('undefined') => undef);

};

subtest 'Check get_all method' => sub {

    my $redis = Optique::Redis->new($redis_type => $redis_server);

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
    cmp_deeply($redis->get_all => $expected);

};

subtest 'Check delete method' => sub {

    my $redis = Optique::Redis->new($redis_type => $redis_server);

    $redis->delete('num1');
    is($redis->get('num1') => undef);

    $redis->delete('str2');
    is($redis->get('str2') => undef);

    my $expected = set(
        { key => 'num0', value => 0, },
        { key => 'num2', value => 456, },
        { key => 'num3', value => 789, },
        { key => 'str0', value => '', },
        { key => 'str1', value => 'hoge', },
        { key => 'str3', value => 'fizz', },
        { key => 'str4', value => 'buzz', },
    );
    cmp_deeply($redis->get_all => $expected);

};

subtest 'Check flush_all method' => sub {

    my $redis = Optique::Redis->new($redis_type => $redis_server);
    $redis->flush_all();

    is($redis->get('num0') => undef);
    is($redis->get('num1') => undef);
    is($redis->get('num2') => undef);
    is($redis->get('num3') => undef);
    is($redis->get('str0') => undef);
    is($redis->get('str1') => undef);
    is($redis->get('str2') => undef);
    is($redis->get('str3') => undef);
    is($redis->get('str4') => undef);

};

done_testing;
