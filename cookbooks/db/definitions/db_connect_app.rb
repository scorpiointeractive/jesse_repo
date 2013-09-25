#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Sets up config file to connect application servers with database servers.
#
# @param template [String] Name of template that sets up the config file.
# @param cookbook [String] Name of cookbook that called this definition.
# @param database [String] Name of the database.
# @param driver_type [String] Type of driver to configure.
# @param owner [String] The name of the owner.
# @param group [String] The name of the group the owner belongs to.
# @param vars [Hash] Additional variables required in the template.
#
define(:db_connect_app,
  :template => "db_connection_example.erb",
  :cookbook => "db",
  :database => nil,
  :driver_type => nil,
  :owner => nil,
  :group => nil,
  :vars => {}
) do

  # The action "install_client_driver" is implemented in db_<provider> cookbook's provider/default.rb
  db node[:db][:data_dir] do
    driver_type params[:driver_type]
    action :install_client_driver
  end

  template params[:name] do
    source params[:template]
    cookbook params[:cookbook]
    mode "0440"
    owner params[:owner]
    group params[:group]
    backup false
    variables(
      :user => node[:db][:application][:user],
      :password => node[:db][:application][:password],
      :fqdn => node[:db][:dns][:master][:fqdn],
      :socket => node[:db][:socket],
      :database => params[:database],
      :port => node[node[:db][:provider]][:port],
      :vars => params[:vars]
    )
  end

end
