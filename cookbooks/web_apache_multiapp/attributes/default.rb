#
# Cookbook Name:: web_apache_multiapp
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# worker = multithreaded (when you need a great deal of scalability)
# prefork = single-threaded (when you need stability or compatibility with older software)
# for more info please visit: http://httpd.apache.org/docs/2.0/en/mpm.html
default[:web_apache_multiapp][:mpm] = "prefork"

# Distribution specific config dir
case platform
when "ubuntu"
  set[:web_apache_multiapp][:config_subdir] = "apache2"
when "centos", "redhat"
  set[:web_apache_multiapp][:config_subdir] = "httpd"
end

# Optional attributes

# Multi processing module
default[:web_apache_multiapp][:mpm] = "prefork"
# Multi app JSON data
default[:web_apache_multiapp][:apps_json] = '{
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
# Application name
default[:web_apache_multiapp][:application_name] = "myapp"
# Allow override default value
default[:web_apache_multiapp][:allow_override] = "None"

# Apache document root
set[:web_apache_multiapp][:docroot] = "/home/webapps/#{web_apache_multiapp[:application_name]}"

# Default servername for web_apache_multiapp vhost file
set[:web_apache_multiapp][:server_name] = "localhost"

# Maintenance mode attributes
set[:web_apache_multiapp][:maintenance_file] = "/home/webapps/system/maintenance.html"
