Mojolicious-Plugin-RedirectHost [![Build Status](https://travis-ci.org/alexbyk/Mojolicious-Plugin-RedirectHost.svg)](https://travis-ci.org/alexbyk/Mojolicious-Plugin-RedirectHost)
========

Going to change your domain name but worry about seo ranks of your site? 
Or maybe trying to improve seo rank by keeping only one version of your domain (with www or without)

That's what you're looking for.

Plugin redirects all requests from mirrors (all request with a `Host` header not equal to the provided `host` option) to the only one host (domain);

	www.main.host       => main.host
	another.io/foo?bar  => main.host/foo?bar
	etc...

You can point as many domains to your App by DNS, as you want. It doesn't matter, all of them will become a mirror. An equivalent apache .htaccess file looks like

	RewriteCond %{HTTP_HOST}   !^alexbyk.com
	RewriteRule  ^(.*)		http://alexbyk.com/$1 [R=301,L]

It's possible to redirect all requests except /robots.txt using 'er' option. That's made for Yandex search engine. It's for SEO optimization only.
If you don't know what that, just ignore that option and don't mind

Use your_app.production.conf file to avoid redirecting localhost

Installation
----------

You can install this plugin from CPAN

	cpanm Mojolicious::Plugin::RedirectHost

	cpan -i Mojolicious::Plugin::RedirectHost

or using any of your favourite cpan manager

Usage
----------

To redirect all requests to the main.host with 301 code (permanent) by default

```perl
# Mojolicious
$app->plugin('RedirectHost', host => 'main.host');
 
# Mojolicious::Lite
plugin RedirectHost => { host => 'main.host' };
```

The best practise is to use an you_app.production.conf file to avoid redirection while developing in your local machine

```
# in your_app.production.conf
{
  redirect_host => {host => 'main.host'},
	#... other stuff
}
```

```perl
# in lib/YourApp.pm
$app->plugin('Config');
$app->plugin('RedirectHost');
```

Options
-------------------------
Take a look at the cpan repository [page](https://metacpan.org/pod/Mojolicious::Plugin::RedirectHost) for the options details
