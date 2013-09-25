maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "RightScale load balancer cookbook for Apache/HAProxy. This" +
                 " cookbook provides recipes for setting up and running an" +
                 " Apache/HAProxy load balancer server as well as recipes for" +
                 " attaching and detaching application servers."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

supports "centos"
supports "redhat"
supports "ubuntu"

depends "rightscale"
depends "app"
depends "lb"

recipe "lb_haproxy_multiapp::setup_server",
  "This loads the required 'lb' resource using the HAProxy provider."

recipe "lb_haproxy_multiapp::install_cloudflare_cron",
  "Install cloudflare cron task and its associated scripts"

attribute "lb_haproxy_multiapp/algorithm",
  :display_name => "Load Balancing Algorithm",
  :description =>
    "The algorithm that the load balancer will use to direct traffic." +
    " Example: roundrobin",
  :required => "optional",
  :default => "roundrobin",
  :choice => ["roundrobin", "leastconn", "source"],
  :recipes => [
    "lb_haproxy_multiapp::setup_server"
  ]

attribute "lb_haproxy_multiapp/timeout_server",
  :display_name => "Server Timeout",
  :description =>
    "The maximum inactivity time on the server side to direct traffic." +
    " Example: 60000",
  :required => "optional",
  :default => "60000",
  :recipes => [
    "lb_haproxy_multiapp::setup_server"
  ]

attribute "lb_haproxy_multiapp/timeout_client",
  :display_name => "Client Timeout",
  :description =>
    "The maximum inactivity time on the client side in milliseconds." +
    " Example: 60000",
  :required => "optional",
  :default => "60000",
  :recipes => [
    "lb_haproxy_multiapp::setup_server"
  ]
