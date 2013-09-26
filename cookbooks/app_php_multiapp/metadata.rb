maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Cookbook provides Apache + PHP implementation of the 'app'" +
                 " LWRP. Installs and configures, Apache + PHP application server."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

supports "centos"
supports "redhat"
supports "ubuntu"

depends "app"
depends "repo"
depends "rightscale"
depends "web_apache"

recipe "app_php_multiapp::setup_server_5_3",
  "Installs the php application server."

recipe "app_php_multiapp::change_rpaf_config",
  "Updates rpaf configuration with ip address of each load balancers."

recipe "app_php_multiapp::install_svn_sync",
  "Installs Jesse SVN sync script and its associated files"

attribute "app_php_multiapp",
  :display_name => "PHP Application Settings",
  :type => "hash"

attribute "app_php_multiapp/modules_list",
  :display_name => "PHP module packages",
  :description =>
    "An optional list of php module packages to install. Accepts an array" +
    " of package names. When using CentOS, package names are prefixed with" +
    " php53u instead of php. To see a list of available php modules on" +
    " CentOS, run 'yum search php53u' on the server." +
    " Example: php53u-mysql, php53u-pecl-memcache",
  :required => "optional",
  :type => "array",
  :recipes => ["app_php_multiapp::setup_server_5_3"]

attribute "app_php_multiapp/apps_json",
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
}'
