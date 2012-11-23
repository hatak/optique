package t::Util;
use warnings;
use strict;

use Test::More 0.98;
use Test::TCP;
use Test::RedisServer;;

{
    # utf8 hack.
    binmode Test::More->builder->$_, ":utf8" for qw/output failure_output todo_output/;
    no warnings 'redefine';
    my $code = \&Test::Builder::child;
    *Test::Builder::child = sub {
        my $builder = $code->(@_);
        binmode $builder->output,         ":utf8";
        binmode $builder->failure_output, ":utf8";
        binmode $builder->todo_output,    ":utf8";
        return $builder;
    };
}

# initialize daemons
our @MEMCACHED;
our $REDIS;

sub run_redis {

    diag "Checking for explicit TEST_REDIS_SERVER";
    # do we have an explicit redis-server somewhere?
    if (my $server = $ENV{TEST_REDIS_SERVER}) {
        return $server;
    }

    eval {
        $REDIS = Test::RedisServer->new();
        my @conf = ($REDIS->connect_info);
        diag "Starting redis on @conf";
        return @conf;
    } or plan skip_all => 'redis-server is required to this test';
}

sub run_memcached {

    diag "Checking for explicit TEST_MEMCACHED_SERVERS";
    # do we have an explicit memcached somewhere?
    if (my $servers = $ENV{TEST_MEMCACHED_SERVERS}) {
        return $servers;
    }

    # Test::TCP (memcached)
    my $max = $ENV{TEST_MEMCACHED_COUNT} || 2;
    eval {
        for my $i (1..$max) {
            push @MEMCACHED, Test::TCP->new(code => sub {
                    my $port = shift;
                    diag "Starting memcached $i on 127.0.0.1:$port";
                    exec "memcached -l 127.0.0.1 -p $port";
                });
        }

        my @servers = map { '127.0.0.1:' . $_->port } @MEMCACHED;

        return \@servers;
} or plan skip_all => 'memcached is required to this test';
}

END {
    # destroy instance
    undef @MEMCACHED && diag "Destroy memcached daemons";
    undef $REDIS;
}

1;
