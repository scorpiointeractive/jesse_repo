#
# Cookbook Name:: lb_haproxy_multiapp
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Haproxy algorithm
default[:lb_haproxy_multiapp][:algorithm] = 'roundrobin'
# Haproxy client timeout
default[:lb_haproxy_multiapp][:timeout_client] = '60000'
# Haproxy server timeout
default[:lb_haproxy_multiapp][:timeout_server] = '60000'

# HAProxy tuning parameters
default[:lb_haproxy_multiapp][:global_maxconn] = 4096
default[:lb_haproxy_multiapp][:default_maxconn] = 2000
default[:lb_haproxy_multiapp][:httpclose] = "off"
default[:lb_haproxy_multiapp][:abortonclose] = "off"
