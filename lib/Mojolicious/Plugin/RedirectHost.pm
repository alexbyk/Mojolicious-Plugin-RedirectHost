package Mojolicious::Plugin::RedirectHost;

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::URL;

our $VERSION = '0.05';

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


=head1 NAME

Mojolicious::Plugin::RedirectHost - Redirects requests from mirrors to the main host (useful for SEO)

=head1 VERSION

Version 0.05


=head1 SYNOPSIS


Generate 301 redirect from C<http://mirror.main.host/path?query> to C<http://main.host/path?query>
  
  # Mojolicious
  $app->plugin('RedirectHost', host => 'main.host');
  
  # Mojolicious::Lite
  plugin RedirectHost => { host => 'main.host' };

All requests with C<Host> header not equal to the C<host> option will be redirected to the main host

=head1 OPTIONS/USAGE

=head2 C<host>

Main domain. All requests to the mirrors will be redirected to the C<host> (domain)
This option is required. Without it plugin do nothing

=head2 C<code>

  $app->plugin('RedirectHost', host => 'main.host', code => 302);

Type of redirection. Default 301 (Moved Permanently)

=head2 C<except_path>

  $app->plugin('RedirectHost', host => 'main.host', except_path => '/robots.txt');

If the path of the request will match C<except_path> value, redirection will be avoid.
Path must begin with leading '/';
Usefull to avoid /robots.txt redirections
In the future maybe I'll make this parameter more flexible

=head2 C<url>

All keys of the C<url> hash (except C<query>) become L<Mojo::URL> object's methods, regarding old request
  
  # 302: http://mirror.main.host/path?query -> http://main.host/path?query
  $app->plugin('RedirectHost', host => 'main.host', code => 302);

You can replace some parts of the old request, for example scheme (C<https>), or add extra query parameters C<?a=b> to the end

  # http://mirror.main.host/foo -> https://main.host/foo?a=b
  $app->plugin(
    'RedirectHost',
    host   => 'main.host',    
    url => { scheme => 'https', query  => [{a => 'b'}] }
  );


How to use url->{query} option (pay attention to '[]')

  # append ?a=old&foo=bar -> ?a=old&foo=bar&a=b
  url => {query => [{a => 'b'}]

  # merge ?a=old&foo=bar -> ?a=b&foo=bar
  url => {query => [[a => 'b']]
  
  # replace ?a=old&foo=bar -> ?a=b
  url => {query => [a => 'b']}
  
  # this works too
  url => {query => [Mojo::Parameters->new(a => 'b')]}
  
  # Wrong!!! Don't do this. Don't forget []
  url => {query => Mojo::Parameters->new(a => 'b')}

See L<Mojo::URL/query>

You can pass a string to the C<url> part of options

  # http://mirror.main.host/foo -> http://google.com
  $app->plugin(
    'RedirectHost',
    host   => 'main.host',    
    url => 'http://google.com'
  );
  

New url as an L<Mojo::URL> object

  # http://mirror.main.host/foo -> http://google.com
  $app->plugin(
    'RedirectHost',
    host => 'main.host',    
    url  => Mojo::URL->new('http://google.com')
  );

=head1 CONFIG

You can pass options to the plugin with the help of your config. Use C<redirect_host> key.

  $app->config(redirect_host => {host => 'main.host'});

=head1 METHODS

=head2 register

Register. См L<Mojolicious::Plugin/register>

=head1 TODO

Play around requests without "Host" header like this:
  
  GET / HTTP/1.1


=head1 AUTHOR

Alex, C<< <alexbyk at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-mojolicious-plugin-redirecthost at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Mojolicious-Plugin-RedirectHost>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Mojolicious::Plugin::RedirectHost


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Mojolicious-Plugin-RedirectHost>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Mojolicious-Plugin-RedirectHost>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Mojolicious-Plugin-RedirectHost>

=item * Search CPAN

L<http://search.cpan.org/dist/Mojolicious-Plugin-RedirectHost/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2014 Alex.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;    # End of Mojolicious::Plugin::RedirectHost
