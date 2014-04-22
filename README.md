Mojolicious-Plugin-RedirectHost
========

Going to change your domain name but worry about seo ranks of your site? 
Or maybe trying to improve seo rank by keeping only one version of your domain (with www or without)

That's what you're looking for.

Plugin redirects all requests from mirrors to the only one host (domain);

	mirror.main.host => main.host
	www.main.host/foo?bar => main.host/foo?bar
	etc...

It's possible to redirect all requests except /robots.txt using 'er' option. That's made for Yandex search engine. It's for SEO optimization only.
If you don't know what that, just ignore that option and don't mind

Use your_app.production.conf file to avoid redirecting localhost

Installation
----------

You can install this plugin from CPAN

	cpanm Mojolicious::Plugin::RedirectHost

	cpan -i Mojolicious::Plugin::RedirectHost

or using any of your favourite cpan manager
