# RightScale Web Apache Cookbook

## DESCRIPTION:

This cookbook installs and configures an Apache2 web server with multiple web applications and SSL support.

## REQUIREMENTS:

Requires a virtual machine launched from a RightScale managed RightImage.

## COOKBOOKS DEPENDENCIES:

Please see `metadata.rb` file for the latest dependencies.

## KNOWN LIMITATIONS:

There is no support for SSL Passphrases.

## SETUP/USAGE:

* Place the `web_apache_multiapp::install_server` recipe into your runlist to set up the
  apache web server.
* Use the `web_apache_multiapp::setup_monitoring` recipe to add apache monitoring options
  to your dashboard "Monitoring" tab.

## DETAILS:

### General

The recipes in this cookbook are designed to perform basic operations on an
apache web server.

### Attributes:

Detailed cookbook attributes descriptions you can find in attributed/default.rb
file

## Templates:

* `apache.conf.erb` -
  Configuration for apache vhost file.
* `apache_collectd_exec.erb` -
  Collectd exec plugin configuration template.
* `apache_collectd_plugin.conf.erb` -
  Collectd status plugin configuration template.
* `apache_ssl_vhost.erb` -
  Configuration for apache ssl vhost file.
* `apache_status.conf.erb` -
  Configuration for apache status information access.
* `maintenance.conf.erb` -
  Configuration for apache maintenance mode setup.
* `ssl_certificate.erb` -
  Apache ssl certificate path template.
* `ssl_certificate_chain.erb` -
  Apache ssl certificate chain path template.
* `ssl_key.erb` -
  Apache ssl key template.
* `sysconfig_httpd.erb` -
  Configuration file template for the apache service.

## LICENSE

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement..
