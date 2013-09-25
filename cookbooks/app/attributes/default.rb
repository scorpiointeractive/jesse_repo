#
# Cookbook Name:: app
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Set a default provider for app to connect with lb cookbook attach/detach
# for application servers without their own provider.
default[:app][:provider] = "app"
# By default listen on the first private IP
default[:app][:ip] = node[:cloud][:private_ips][0]
# IP addrs of loadbalancer requesting firewall ports to be opened to it
default[:app][:lb_private_ip] = ""
default[:app][:lb_public_ip] = ""

# Recommended attributes

# Application listen port
default[:app][:port] = "8000"
# The database schema name the app server uses
default[:app][:database_name] = ""
# Application IP type given to the load balancer. Possible values for this
# attribute are "public" and "private".
default[:app][:backend_ip_type] = "private"
