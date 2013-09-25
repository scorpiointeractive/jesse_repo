#
# Cookbook Name:: sys
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# @resource sys_reconverge

# Enable cookbook reconverge
action :enable do
  recipe = new_resource.recipe_name
  interval = new_resource.interval
  splay = node[:sys][:reconverge][:splay].to_i

  # Calls the randomize_reconverge_minutes in helper class which is found in
  # cookbooks/rightscale/libraries/helper.rb
  minute_list = RightScale::System::Helper.randomize_reconverge_minutes(
    interval,
    splay
  )

  log "  Adding #{recipe} to reconverge via cron on minutes [#{minute_list}]"

  cron "reconverge_#{recipe.gsub("::", "_")}" do
    minute minute_list
    user "root"
    command "rs_run_recipe --policy '#{recipe}' --name '#{recipe}' 2>&1 >>" +
      " /var/log/rs_sys_reconverge.log"
    action :create
  end

end

# Disable cookbook reconverge
action :disable do
  recipe = new_resource.recipe_name
  log "  Removing #{recipe} from reconverge via cron"

  cron "reconverge_#{recipe.gsub("::", "_")}" do
    user "root"
    action :delete
  end
end
