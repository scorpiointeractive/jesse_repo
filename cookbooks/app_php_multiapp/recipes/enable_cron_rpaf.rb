#Cookbook Name:: app_php_multiapp

rightscale_marker

class Chef::Recipe
  include RightScale::App::Helper
end

log "  Enabling cron rpaf"

cron_name = "rpaf_config_changer"
recipe = "app_php_multiapp::change_rpaf_config"
log_file = "/tmp/#{cron_name}.log"

cron "#{cron_name}" do
  user "root"
  command "rs_run_recipe --policy '#{recipe}' --name '#{recipe}' 2>&1 >> #{log_file}"
  action :create
end
