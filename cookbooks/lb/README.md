# RightScale Load Balancer Cookbook 

## DESCRIPTION:

This cookbook provides a set of load balancer recipes used by RightScale's
Load Balancer ServerTemplates.

This cookbook is intended to provide an interface for general load balancer
actions and parameters.

## DETAILS:

### General
The 'lb' interface is defined by a Lightweight Resource, which can be found in
the `resources/default.rb` file.

This cookbook is intended to be used in conjunction with cookbooks that contain
Lightweight Providers that implement the 'lb' interface. See the RightScale
`lb_haproxy` cookbook for an example.

To review information about Lightweight Resources and Providers (LWRPs), see
[Lightweight Resources and Providers][LWRP].

[LWRP]: http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/04-Developer/06-Development_Resources/Lightweight_Resources_and_Providers_(LWRP)

## REQUIREMENTS:

* Requires a virtual machine launched from a RightScale-managed RightImage.

## SETUP:

## USAGE:

### Application Server Attach

#### do_attach_request

This recipe is used by application servers to request that load balancer servers
configure themselves to attach to the application server.

#### handle_attach recipes

This recipe is used by a load balancer server to add an application server to
its configuration when the application server requests it, and restart,
if necessary.

### Application Server Detach

#### do_detach_request

This recipe is used by application servers to request that load balancer servers
configure themselves to detach from the application server.

#### handle_detach recipes

This recipe is used by a load balancer server to remove an application server
from its configuration when the application server requests it, and restart,
if necessary.

### Automatic Server Detection

#### do_attach_all recipe

This recipe is used by the load balancer to automatically detect whether
application servers have disappeared or reappeared, without detaching or
reattaching using the other recipes. This recipe is set to run in a periodic
reconverge, which, by default, runs every 15 minutes.

## RESOURCES

### lb_client (providers/client.rb)

There is a generic lb_client resource provider included in this cookbook. This
provider is intended to be used on application servers that need to attach to a
load balancer. The lb_client provider only supports the :attach_request and
:detach_request actions.

The :attach_request and :detach_request actions will send a remote recipe to all
load balancers in the deployment with the "loadbalancer:&lt;pool_name&gt;=lb"
machine tag.  The :attach_request action will request them to run the
"lb::handle_attach" recipe.  The :detach_request will request them to run the
"lb::handle_dettach" recipe.

Example of an application server requesting to be attached to the "www" vhost:

    lb "www" do
      backend_id "my-webserver-#{node[:rightscale][:instance_uuid]}"
      backend_ip node[:app][:ip]
      backend_port node[:app][:port].to_i
      action :attach_request
    end
  
For more examples see the lb::do_attach_request and lb::do_detach_request
recipes.

## KNOWN LIMITATIONS:

There are no known limitations.

## LICENSE

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
