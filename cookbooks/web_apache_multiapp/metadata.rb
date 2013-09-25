maintainer       "Scorpio Media"
maintainer_email "tom@scorp.io"
license          "Copyright Scorpio Media, Inc. All rights reserved."
description      "This cookbook installs and configures an Apache2 web server with multiple web applications."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

supports "centos"
supports "redhat"
supports "ubuntu"

recipe "web_apache_multiapp::default",
  "Runs web_apache_multiapp::install_apache."

recipe "web_apache_multiapp::do_start",
  "Runs service apache start."

recipe "web_apache_multiapp::do_stop",
  "Runs service apache stop."

recipe "web_apache_multiapp::do_restart",
  "Runs service apache restart."

recipe "web_apache_multiapp::do_enable_default_site",
  "Enables the default vhost."

recipe "web_apache_multiapp::install_apache",
  "Installs and configures the Apache2 webserver."

recipe "web_apache_multiapp::setup_frontend_multiapp",
  "Sets up front-end apache vhost depending on the JSON application config data. Supports SSL, without passphrases."

recipe "web_apache_multiapp::setup_monitoring",
  "Installs the collectd-apache plugin for monitoring support."

recipe "web_apache_multiapp::do_enable_maintenance_mode",
  "Enables maintenance mode for Apache2 webserver"

recipe "web_apache_multiapp::do_disable_maintenance_mode",
  "Disables maintenance mode for Apache2 webserver"

depends "apache2"
depends "rightscale"

attribute "web_apache_multiapp",
  :display_name => "apache hash",
  :description =>
    "Apache Web Server",
  :type => "hash"

attribute "web_apache_multiapp/mpm",
  :display_name => "Multi-Processing Module",
  :description =>
    "Defines the multi-processing module setting in httpd.conf." +
    " Use 'worker' for Rails/Tomcat/Standalone frontends" +
    " and 'prefork' for PHP. Example: prefork",
  :required => "optional",
  :recipes => [
    "web_apache_multiapp::default",
    "web_apache_multiapp::install_apache",
    "web_apache_multiapp::setup_frontend_multiapp",
  ],
  :choice => ["prefork", "worker"],
  :default => "prefork"

attribute "web_apache_multiapp/apps_json",
  :display_name => "JSON Application config data",
  :description => "Hosts the server name, aliases, ssl info, and SVN info" + 
					" for multiple web applications. The format is as follows: " +
					"{\"sites\":[{\"name\":\"example.com\", \"aliases\":[\"ex.am.pl\"," +
					"\"ex.ample.com\"], \"ssl_cert\"=\"<SSL cert contents>\"," +
					"\"ssl_key\"=\"<SSL key contents>\"," +
					"\"ssl_chain\"=\"<SSL chain contents>\", \"svn_remote_repo\":" +
					"\https://svn.myrepo.com/project/\"}]} of multiple sites/applications." +
					" Aliases and ssl are optional.",
  :default => '{
   "sites":[
      {
         "name":"example.com",
         "aliases":[
            "www.example.com",
            "ex.am.pl"
         ],
         "ssl_cert":"BEGIN CERTIFICATE AAAAA END CERTIFICATE",
         "ssl_key":"BEGIN RSA PRIVATE KEY BBBBB END RSA PRIVATE KEY",
         "ssl_chain":"BEGIN CERTIFICATE CCCCC END CERTIFICATE",
         "svn_remote_repo":"https://subversion.assembla.com/svn/my-project/branches/production/"
      }
   ]
}',
  :recipes => ["web_apache_multiapp::setup_frontend_multiapp"]

attribute "web_apache_multiapp/application_name",
  :display_name => "Application Name",
  :description =>
    "Sets the directory for your application's web files" +
    " (/home/webapps/Application Name/). If you have multiple applications," +
    " you can run the code checkout script multiple times, each with a" +
    " different value for the 'Application Name' input, so each application" +
    " will be stored in a unique directory." +
    " This must be a valid directory name. Do not use symbols in the name." +
    " Example: myapp",
  :required => "optional",
  :default => "myapp",
  :recipes => [
    "web_apache_multiapp::setup_frontend_multiapp",
    "web_apache_multiapp::default"
  ]

attribute "web_apache_multiapp/allow_override",
  :display_name => "AllowOverride Directive",
  :description =>
    "Allows/disallows the use of .htaccess files in project web root" +
    " directory. Can be None (default), All, or any directive-type" +
    " as specified in Apache documentation. Example: None",
  :required => "optional",
  :choice => ["None", "All"],
  :default => "None",
  :recipes => [
    "web_apache_multiapp::setup_frontend_multiapp",
    "web_apache_multiapp::default"
  ]
