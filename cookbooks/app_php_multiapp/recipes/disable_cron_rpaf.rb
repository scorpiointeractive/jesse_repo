#Cookbook Name:: app_php_multiapp

rightscale_marker

class Chef::Recipe
  include RightScale::App::Helper
end

log "  Disabling cron rpaf"

cron_name = "rpaf_config_changer"

cron "#{cron_name}" do
  user "root"
  action :delete
end
