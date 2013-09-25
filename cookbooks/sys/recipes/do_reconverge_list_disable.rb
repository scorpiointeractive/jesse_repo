#
# Cookbook Name:: sys
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

# Remove re-converge task for all recipes provided in
# the space-separated reconverge_list.
node[:sys][:reconverge_list].split(" ").each do |recipe|

  log "  Removing re-converge task for #{recipe}"

  # This block calls the disable action of cookbooks/sys/providers/default.rb
  # by passing in the recipe name as the parameter.
  sys_reconverge "Disable recipe re-converge" do
    recipe_name recipe
    action :disable
  end

end if node[:sys]
