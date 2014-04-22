package Mojolicious::Plugin::RedirectHost;

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::URL;

# VERSION

# where to look for options
my $CONFIG_KEY   = 'redirect_host';
my $DEFAULT_CODE = 301;

sub register {
  my ($self, $app, $params) = @_;

  my %options;
  if (ref $params eq 'HASH' && scalar keys %$params) {
    %options = %$params;
  }
  elsif (ref $app->config($CONFIG_KEY) eq 'HASH') {
    %options = %{$app->config($CONFIG_KEY)};
  }

  unless ($options{host}) {
    $app->log->error('RedirectHost plugin: define "host" option at least!');
    return;
  }

  $app->hook(
    before_dispatch => sub {
      my $c    = shift;
      my $url  = $c->req->url->to_abs;
      my $path = $c->req->url->path;


      # don't need redirection
      return if $url->host eq $options{host};

      # TODO: check if except_path is RE or ARR
      # path match exception
      if (my $except_path = $options{except_path}) {
        return if $path eq $except_path;
      }

      # main host
      $url->host($options{host});

      #$url->host(delete local $options{host});

      # code
      $c->res->code($options{code} || $DEFAULT_CODE);

      #$c->res->code(delete local $options{code} || $DEFAULT_CODE);

      if (ref $options{url} eq 'HASH') {

        # query
        if (ref $options{url}->{query} eq 'ARRAY') {
          my @query = @{delete $options{url}->{query}};
          $url->query(@query);

        }

        # замещаем значения
        foreach my $what (keys %{$options{url}}) {
          $url->$what($options{url}->{$what}) if $options{url}->{$what};
        }
      }
      elsif (ref $options{url}) {

        # replace a whole url with a passed Mojo::URL object
        $url = $options{url};
      }
      elsif ($options{url}) {

        # replace a whole url with a new one
        $url = Mojo::URL->new($options{url});
      }


      $c->redirect_to($url->to_string);
    }
  );

  return;
}

1;
# ABSTRACT: Redirects requests from mirrors to the main host (useful for SEO)

=head1 SYNOPSIS


Generates 301 redirect from C<http://mirror.main.host/path?query> to C<http://main.host/path?query>
  
  # Mojolicious
  $app->plugin('RedirectHost', host => 'main.host');
  
  # Mojolicious::Lite
  plugin RedirectHost => { host => 'main.host' };

All requests with C<Host> header that are not equal to the C<host> option will be redirected to the main host
It would be better if you'll be using per mode config files (your_app.production.conf etc). This would make possible
to redirect only in production enviropment (but do nothing while coding your app)

=head1 OPTIONS/USAGE

=head2 C<host>

Main domain. All requests to the mirrors will be redirected to the C<host> (domain)
This option is required. Without it plugin do nothing

=head2 C<code>

  $app->plugin('RedirectHost', host => 'main.host', code => 302);

Type of redirection. Default 301 (Moved Permanently)

=head2 C<er> (except /rotots.txt)

  $app->plugin('RedirectHost', host => 'main.host', er => 1);

If true, requests like /robots.txt will not be redirected but rendered. That's for Yandex search engine.
If you want to change a domain but worry about yandex TIC, it's recomended to make it possible for Yandex to read your robots.txt
with new Host directive. If so, that's exactly what you're looking for

=head1 CONFIG

You can pass options to the plugin with the help of your config. Use C<redirect_host> key.

  $app->config(redirect_host => {host => 'main.host'});

TIP: use per mode config files (yourapp.production.conf) to pass parameters to the plugin to avoid redirection during
development process

=head1 METHODS

=head2 register

Register.  L<Mojolicious::Plugin/register>

=head1 TODO

Play around requests without "Host" header like this:
  
  GET / HTTP/1.1


