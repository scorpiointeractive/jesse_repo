Cookbook Name:: app_php_multiapp

rightscale_marker

class Chef::Recipe
  include RightScale::App::Helper
end

pool_names(node[:lb][:pools]).each do |pool_name|
  app_php_multiapp "Update rpaf config" do
    machine_tag "loadbalancer:#{pool_name}=lb"
    ip_tag "server:#{node[:app][:backend_ip_type]}_ip_0"
    action :update_rpaf
  end
end
