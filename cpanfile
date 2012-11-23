requires 'Plack';
recommends 'Plack::Middleware::ReverseProxy';
requires 'Cache::Memcached';
requires 'Redis';

on 'test' => sub {
    requires 'Test::More', '>= 0.98, < 2.0';
    requires 'Module::Find';
    recommends 'Test::RedisServer';
    recommends 'Test::Pretty';
};
