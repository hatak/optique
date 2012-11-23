package Optique::Memcached;
use warnings;
use strict;

use Cache::Memcached;

sub new {
    my $class = shift;
    my $args  = ref($_[0]) eq 'HASH' ? $_[0] : {@_};

    my $servers = ( ref($args->{servers}) eq 'ARRAY' && @{$args->{servers}} ) ? $args->{servers} : [ 'localhost:11211' ];

    my $memd = Cache::Memcached->new(
        servers => $servers,
        connect_timeout => 0.25,
        io_timeout      => 1.0,
        close_on_error  => 1,
        utf8 => 1,
    );

    return bless +{ servers => $servers, _memd => $memd }, $class;
}

sub get {
    my ($self, $key) = @_;

    return $self->{_memd}->get($key);
}

sub set {
    my ($self, $key, $value, $exptime) = @_;

    return $self->{_memd}->set($key => $value, $exptime);
}

sub delete {
    my ($self, $key) = @_;

    return $self->{_memd}->delete($key);
}

sub flush_all {
    my $self = shift;

    return $self->{_memd}->flush_all();
}

sub get_all {
    my $self = shift;

    # refer to memcached-tool
    # https://github.com/memcached/memcached/blob/master/scripts/memcached-tool
    my @values;

    my $mc = $self->{_memd};
    # get slabs with "stats items"
    my $s_items = $mc->stats(['items']);
    for my $host (keys %{$s_items->{hosts}}) {
        for my $row (split /\r/, $s_items->{hosts}{$host}{items}) {
            if ($row  =~ /STAT items:(\d*):number (\d*)/) { # $1:slab_id $2:num
                my ($slab_id , $num) = ($1, $2);

                # get chank with "stats cachedump"
                my $cmd_str = sprintf 'cachedump %d %d', $slab_id, $num;
                my $s_cachedump = $mc->stats([$cmd_str]);
                for my $row (split /\r/, $s_cachedump->{hosts}{$host}{$cmd_str}) {
                    if ($row  =~ /ITEM (\S+) \[.* (\d+) s\]/) { # $1:key $2:expire_ts
                        my $key = $1;
                        push @values, +{ key => $key, value => $mc->get($key) };
                    }
                }
            }
        }
    }

    return \@values;
}

1;
