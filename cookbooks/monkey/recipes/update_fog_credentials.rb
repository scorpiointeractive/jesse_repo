#
# Cookbook Name:: monkey
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

log "  Updating fog credentials"
template "/root/.fog" do
  source "fog.erb"
  variables(
    :creds => node[:monkey][:fog]
  )
end
