maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "This cookbook provides a set of load balancer recipes used" +
                 " by the RightScale Load Balancer ServerTemplates. This" +
                 " cookbook does not  contain a specific load balancer" +
                 " implementation, but generic recipes that use the LWRP interface."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

supports "centos"
supports "redhat"
supports "ubuntu"

depends "lb_haproxy_multiapp"
depends "lb_clb"
depends "lb_elb"
depends "apache2"
depends "app", ">= 1.0"

recipe "lb::default",
  "This loads the required load balancer resources."

recipe "lb::install_server",
  "Installs the load balancer and adds the loadbalancer:<pool_name>=lb tags" +
  " to your server, which identifies it as a load balancer for a given" +
  " listener pool. This tag is used by application servers to request" +
  " connection/disconnection."

recipe "lb::handle_attach",
  "Remote recipe executed by do_attach_request. DO NOT RUN."

recipe "lb::handle_detach",
  "Remote recipe executed by do_detach_request. DO NOT RUN."

recipe "lb::do_attach_all",
  "Registers all running application servers" +
  " with the loadbalancer:<pool_name>=app tags. This should be run on a" +
  " load balancer to connect all application servers in a deployment."

recipe "lb::do_attach_request",
  "Sends request to all load balancers to attach the current server to" +
  " the listener pool using given parameters" +
  " (For lb_haproxy - lb/pools input value will be used." +
  " For ELB/CLB - lb/service/* input values will be used)." +
  " This should be run by a new application server" +
  " that is ready to accept connections."

recipe "lb::do_detach_request",
  "Sends request to all load balancers to detach the current server from the" +
  " listener pool  (For lb_haproxy - lb/pools input value will be used." +
  " For ELB/CLB - lb/service/* input values will be used)." +
  " This should be run by an application server at decommission."

recipe "lb::setup_reverse_proxy_config",
  "Configures Apache reverse proxy."

recipe "lb::setup_monitoring",
  "Installs the load balancer collectd plugin for monitoring support."

recipe "lb::setup_advanced_configuration",
  "Sets up advanced load balancer configuration."

attribute "lb/pools",
  :display_name => "Load Balance Pools",
  :description =>
    "Comma-separated list of URIs or FQDNs for which the load balancer" +
    " will create server pools to answer website requests. The order of the" +
    " items in the list will be preserved when answering to requests." +
    " Last entry will be the default backend and will answer for all URIs and" +
    " FQDNs not listed here. A single entry of any name, e.g. 'default', " +
    " 'www.mysite.com' or '/appserver', will mimic basic behavior of" +
    " one load balancer with one pool of application servers. This will be" +
    " used for naming server pool backends. Application servers can provide" +
    " any numbers of URIs or FQDNs to join corresponding server pool" +
    " backends.Example: www.mysite.com, api.mysite.com, /serverid, default",
  :required => "recommended",
  :default => "default",
  :recipes => [
    "lb::default",
    "lb::do_attach_request",
    "lb::handle_attach",
    "lb::do_detach_request",
    "lb::handle_detach",
    "lb::install_server",
    "lb::do_attach_all"
  ]

attribute "lb/stats_uri",
  :display_name => "Status URI",
  :description =>
    "The URI for the load balancer statistics report page." +
    " This page lists the current session, queued session, response error," +
    " health check error, server status, etc. for each load balancer group." +
    " Example: /haproxy-status",
  :required => "optional",
  :default => "/haproxy-status",
  :recipes => [
    "lb::install_server"
  ]

attribute "lb/stats_user",
  :display_name => "Status Page Username",
  :description =>
    "The username that is required to access the load balancer" +
    " statistics report page. Example: cred:STATS_USER",
  :required => "optional",
  :default => "",
  :recipes => [
    "lb::install_server"
  ]

attribute "lb/stats_password",
  :display_name => "Status Page Password",
  :description =>
    "The password that is required to access the load balancer statistics" +
    " report page. Example: cred:STATS_PASSWORD",
  :required => "optional",
  :default => "",
  :recipes => [
    "lb::install_server"
  ]

attribute "lb/session_stickiness",
  :display_name => "Use Session Stickiness",
  :description =>
    "Determines session stickiness. Set to 'True' to use session stickiness," +
    " where the load balancer will reconnect a session to the last server it" +
    " was connected to (via a cookie). Set to 'False' if you do not want to" +
    " use sticky sessions; the load balancer will establish a connection" +
    " with the next available server. Example: true",
  :required => "optional",
  :choice => ["true", "false"],
  :default => "true",
  :recipes => [
    "lb::do_attach_all",
    "lb::handle_attach"
  ]

attribute "lb/health_check_uri",
  :display_name => "Health Check URI",
  :description =>
    "The URI that the load balancer will use to check the health of a server." +
    " It is only used for HTTP (not HTTPS) requests. Example: /",
  :required => "optional",
  :default => "/",
  :recipes => [
    "lb::install_server",
    "lb::handle_attach"
  ]

attribute "lb/service/provider",
  :display_name => "Load Balance Provider",
  :description =>
    "Specify the load balance provider to use either: 'lb_client' for" +
    " ServerTemplate based Load Balancer solutions (such as aiCache, HAProxy," +
    " etc.), 'lb_elb' for AWS Load Balancing, or 'lb_clb' for Rackspace Cloud" +
    " Load Balancing. Example: lb_client",
  :required => "recommended",
  :default => "lb_client",
  :choice => ["lb_client", "lb_clb", "lb_elb"],
  :recipes => [
    "lb::default",
    "lb::do_attach_request",
    "lb::do_detach_request"
  ]

attribute "lb/service/region",
  :display_name => "Load Balance Service Region",
  :description =>
    "For Rackspace's Cloud Load Balancing service region," +
    " specify the cloud region or data center being used for this service." +
    " Example: ORD (Chicago)",
  :required => "optional",
  :default => "ORD (Chicago)",
  :choice => ["ORD (Chicago)", "DFW (Dallas/Ft. Worth)", "LON (London)"],
  :recipes => [
    "lb::default",
    "lb::do_attach_request",
    "lb::do_detach_request"
  ]

attribute "lb/service/lb_name",
  :display_name => "Load Balance Service Name",
  :description =>
    "Name of the Cloud Load Balancer or Elastic Load Balancer device." +
    " Example: mylb",
  :required => "optional",
  :recipes => [
    "lb::default",
    "lb::do_attach_request",
    "lb::do_detach_request"
  ]

attribute "lb/service/account_id",
  :display_name => "Load Balance Service ID",
  :description =>
    "The account name that is required for access to specified" +
    " cloud load balancer. For Rackspace's CLB service," +
    " use your Rackspace username. (e.g., cred: RACKSPACE_USERNAME)." +
    " For Amazon ELB, use your Amazon key ID (e.g., cred:AWS_ACCESS_KEY_ID)." +
    " Example: cred:CLOUD_ACCOUNT_USERNAME",
  :required => "optional",
  :recipes => [
    "lb::default",
    "lb::do_attach_request",
    "lb::do_detach_request"
  ]

attribute "lb/service/account_secret",
  :display_name => "Load Balance Service Secret",
  :description =>
    "The account secret that is required for access to" +
    " specified cloud load balancer. For Rackspace's CLB service," +
    " use your Rackspace account API key (e.g., cred:RACKSPACE_AUTH_KEY)." +
    " For Amazon ELB, use your Amazon secret key" +
    " (e.g., cred:AWS_SECRET_ACCESS_KEY). Example: cred:CLOUD_ACCOUNT_KEY",
  :required => "optional",
  :recipes => [
    "lb::default",
    "lb::do_attach_request",
    "lb::do_detach_request"
  ]
