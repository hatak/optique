package Optique;
use warnings;
use strict;
use utf8;
use parent qw/Amon2/;
our $VERSION='0.01';
use 5.008001;

use Optique::Memcached;
use Optique::Redis;

sub config {
    my $c = shift;

    +{
        'memcached' => [
            'localhost:11211',
        ],
        'redis' => [
            'localhost:6379',
        ],
    }
}

sub memcached {
    my $self = shift;
    if ( !defined $self->{memcached} ) {
        my $conf = $self->config->{memcached}
            or die "missing configuration for 'memcached'";
        $self->{memcached} = Optique::Memcached->new('servers' => $conf);
    }
    return $self->{memcached};
}

sub redis {
    my $self = shift;
    if ( !defined $self->{redis} ) {
        my $conf = $self->config->{redis}
            or die "missing configuration for 'redis'";
        $self->{redis} = Optique::Redis->new('servers' => $conf);
    }
    return $self->{redis};
}

1;
