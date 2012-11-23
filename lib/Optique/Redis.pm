package Optique::Redis;
use warnings;
use strict;

use Redis;

sub new {
    my $class = shift;
    my $args  = ref($_[0]) eq 'HASH' ? $_[0] : {@_};

    my $server = $args->{server} // 'localhost:6379';

    my $redis = Redis->new(
        server => $server,
    );

    return bless +{ server => $server, _redis => $redis }, $class;
}

sub get {
    my ($self, $key) = @_;

    return $self->{_redis}->get($key);
}

sub set {
    my ($self, $key, $value) = @_;

    return $self->{_redis}->set($key => $value);
}

sub delete {
    my ($self, $key) = @_;

    return $self->{_redis}->del($key);
}

sub flush_all {
    my $self = shift;

    return $self->{_redis}->flushall();
}

sub get_all {
    my $self = shift;

    my @values;

    my $redis = $self->{_redis};
    my @keys = $redis->keys('*');
    for my $key (@keys) {
        push @values, +{ key => $key, value => $redis->get($key) };
    }

    return \@values;
}

1;
