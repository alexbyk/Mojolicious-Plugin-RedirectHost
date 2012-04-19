#!/usr/bin/env perl
use utf8;
use Mojo::Base -strict;
require Mojolicious;

use Test::More tests => 18;
use Test::Mojo;
use Mojo::Util 'url_escape';


my $CONFIG_KEY = 'redirect_host';

my $ROUTE = '/f/b/д';
my $URL   = "$ROUTE?1=ы";
my $HOST  = 't.z';
my $OK    = 'http://t.z/f/b/%D0%B4?1=%D1%8B';


# permanent redirection (301) to the same url
DEFAULTS: {
  my $t   = Test::Mojo->new();
  my $app = Mojolicious->new();

  $app->plugin('RedirectHost', host => $HOST);
  $app->routes->get($ROUTE => sub { shift->render_text('ok') });

  $t->app($app);

  # redirect mirrors
  $t->get_ok($URL, {Host => 'mirror223'})->status_is(301)
    ->header_is(Location => $OK);

  # does not need a redirection
  $t->get_ok($URL, {Host => $HOST})->status_is(200)->content_is('ok');
}

# another way to redirect
PARAMS_URL_HASH: {
  my $t   = Test::Mojo->new();
  my $app = Mojolicious->new();

  $app->plugin(
    'RedirectHost',
    host   => $HOST,
    code   => 302,
    url => {
      scheme => 'https',
      port   => 8000,
      path   => '/bar',
      query  => [a => 'b'],
    },    
  );

  $t->app($app)->get_ok('/foo', {Host => 'mirror223'})->status_is(302)
    ->header_is(Location => "https://$HOST:8000/bar?a=b");

  # не забыли ли локализовать удаляемый параметр?
  $t->app($app)->get_ok('/foo', {Host => 'mirror223'})->status_is(302);  
}

# another way to redirect
PARAMS_URL_STRING: {
  my $t   = Test::Mojo->new();
  my $app = Mojolicious->new();

  $app->plugin(
    'RedirectHost',
    host => $HOST,
    url  => 'http://google.com/f?b',
  );

  $t->app($app)->get_ok('/foo', {Host => 'mirror223'})->header_is(Location => "http://google.com/f?b");

}


# another way to redirect
PARAMS_URL_OBJ: {
  my $t   = Test::Mojo->new();
  my $app = Mojolicious->new();

  $app->plugin(
    'RedirectHost',
    host => $HOST,
    url  => Mojo::URL->new('http://mail.ru'),
  );

  $t->app($app)->get_ok('/foo', {Host => 'mirror223'})->header_is(Location => "http://mail.ru");

}





# app->config->{redirect_host}
CONFIG: {
  my $t   = Test::Mojo->new();
  my $app = Mojolicious->new();

  $app->config($CONFIG_KEY => {host => $HOST});
  $app->plugin('RedirectHost');

  $t->app($app)->get_ok('/foo?bar', {Host => 'mirror223'})->status_is(301)
    ->header_is(Location => "http://$HOST/foo?bar");

}


