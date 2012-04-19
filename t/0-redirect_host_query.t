#!/usr/bin/env perl
use utf8;
use Mojo::Base -strict;
use Mojolicious;

use Test::More tests => 8;
use Test::Mojo;

my $HOST = 't.z';

# permanent redirection (301) to the same url

sub testo {
  my @url_params = @_;

  my $t   = Test::Mojo->new();
  my $app = Mojolicious->new();

  $app->plugin('RedirectHost' => host => $HOST, @url_params);
  $t->app($app);
  return $t;
}


# Replace
testo(url => {query => [a => 'b']})->get_ok('/?m=1&a=z', {Host => 'm'})
  ->header_is(Location => "http://$HOST/?a=b");

# Merge
testo(url => {query => [[a => 'b']]})->get_ok('/?m=1&a=z', {Host => 'm'})
  ->header_is(Location => "http://$HOST/?m=1&a=b");
  
  
# Append
testo(url => {query => [{a => 'b'}]})->get_ok('/?m=1&a=z', {Host => 'm'})
  ->header_is(Location => "http://$HOST/?m=1&a=z&a=b");

# new
testo(url => {query => [Mojo::Parameters->new(a => 'b')]})->get_ok('/?m=1&a=z', {Host => 'm'})
  ->header_is(Location => "http://$HOST/?a=b");
