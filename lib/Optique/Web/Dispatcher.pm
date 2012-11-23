package Optique::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::Lite;

any '/' => sub {
    my ($c) = @_;
    return $c->render('index.tt');
};

get '/memcached' => sub {
    my ($c, $args) = @_;
    return $c->render('list.tt' => +{ values => $c->memcached->get_all });
};

get '/redis' => sub {
    my ($c, $args) = @_;
    return $c->render('list.tt' => +{ values => $c->redis->get_all });
};

1;
