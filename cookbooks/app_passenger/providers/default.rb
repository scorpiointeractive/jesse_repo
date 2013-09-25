#
# Cookbook Name:: app_passenger
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# @resource app

# Stops apache/passenger
action :stop do
  log "  Running stop sequence"
  service "apache2" do
    action :stop
    persist false
  end
end

# Starts apache/passenger
action :start do
  log "  Running start sequence"
  service "apache2" do
    action :start
    persist false
  end
end

# Reloads apache/passenger
action :reload do
  log "  Running reload sequence"
  service "apache2" do
    action :reload
    persist false
  end
end

# Restarts apache/passenger
action :restart do
  log "  Running restart sequence"
  # Calls the :stop action.
  action_stop
  sleep 5
  # Calls the :start action.
  action_start
end

# Installs required packages to system
action :install do

  # Installing some apache development headers required for rubyEE
  packages = new_resource.packages
  log "  Packages which will be installed: #{packages}"
  packages.each do |p|
    package p
  end

  # Repopulate gem environment
  gemenv = Chef::ShellOut.new("/usr/bin/gem env")
  gemenv.run_command
  gemenv.error!

  # Reset path to Ruby gem directory
  gemenv.stdout =~ /INSTALLATION DIRECTORY: (.*)$/
  node[:app_passenger][:ruby_gem_base_dir] = $1

  # Resetting passenger binary directory
  gemenv.stdout =~ /EXECUTABLE DIRECTORY: (.*)$/
  node[:app_passenger][:passenger_bin_dir] = $1

  # Installing ruby devel package if not already installed.
  # Required for passenger gem.
  ruby_dev_pkg = value_for_platform(
    ["centos", "redhat"] => {
      "default" => "ruby-devel"
    },
    "ubuntu" => {
      "default" => "ruby-dev"
    }
  )
  log "  Verifying installation of #{ruby_dev_pkg}"
  package ruby_dev_pkg

  # Installing passenger module
  log "  Installing passenger gem"
  gem_package "passenger" do
    gem_binary "/usr/bin/gem"
    version "3.0.19"
    action :install
  end

  log "  Installing apache passenger module"
  bash "Install apache passenger module" do
    flags "-ex"
    code <<-EOH
    PATH=${PATH}:/usr/local/bin
    passenger-install-apache2-module --auto
    EOH
    not_if { ::Dir.glob("#{node[:app_passenger][:ruby_gem_base_dir]}/gems/passenger-*/ext/apache2/mod_passenger.so").any? }

  end

end


# Sets up apache/passenger virtual host
action :setup_vhost do
  port = new_resource.port

  # Removing preinstalled apache ssl.conf as it conflicts with ports.conf of web:apache
  log "  Removing ssl.conf"
  file "/etc/httpd/conf.d/ssl.conf" do
    action :delete
    backup false
    only_if { ::File.exists?("/etc/httpd/conf.d/ssl.conf") }
  end

  log "  Module dependencies which will be installed:" +
    " #{node[:app_passenger][:module_dependencies]}"
  # Enabling required apache modules
  node[:app_passenger][:module_dependencies].each do |mod|
    # See https://github.com/rightscale/cookbooks/blob/master/apache2/definitions/apache_module.rb
    # for the "apache_module" definition.
    apache_module mod
  end

  # Apache fix on RHEL
  file "/etc/httpd/conf.d/README" do
    action :delete
    only_if { node[:platform] == "redhat" }
  end

  # Adds php port to list of ports for webserver to listen on
  # See cookbooks/app/definitions/app_add_listen_port.rb for the "app_add_listen_port" definition.
  app_add_listen_port port.to_s

  log "  Unlinking default apache vhost"
  # See https://github.com/rightscale/cookbooks/blob/master/apache2/definitions/apache_site.rb for the "apache_site" definition.
  apache_site "000-default" do
    enable false
  end

  # Generation of new vhost config, based on user prefs
  log "  Generating new apache vhost"
  project_root = new_resource.root
  # See https://github.com/rightscale/cookbooks/blob/master/apache2/definitions/web_app.rb for the "web_app" definition.
  web_app "http-#{port}-#{node[:web_apache][:server_name]}.vhost" do
    template "basic_vhost.erb"
    cookbook 'app_passenger'
    docroot project_root
    vhost_port port.to_s
    server_name node[:web_apache][:server_name]
    rails_env node[:app_passenger][:project][:environment]
    apache_install_dir node[:app_passenger][:apache][:install_dir]
    apache_log_dir node[:apache][:log_dir]
    ruby_bin node[:app_passenger][:ruby_bin]
    ruby_base_dir node[:app_passenger][:ruby_gem_base_dir]
    rails_spawn_method node[:app_passenger][:rails_spawn_method]
    destination node[:app][:destination]
    apache_serve_local_files node[:app_passenger][:apache][:serve_local_files]
    passenger_user node[:app][:user]
    passenger_group node[:app][:group]
    allow_override node[:web_apache][:allow_override]
  end

end


# Sets up Passenger database connection
action :setup_db_connection do

  deploy_dir = new_resource.destination
  db_name = new_resource.database_name

  log "  Generating database.yml"

  # Tell Database to fill in our connection template
  # See cookbooks/db/definitions/db_connect_app.rb for the "db_connect_app" definition.
  db_connect_app "#{deploy_dir.chomp}/config/database.yml" do
    template "database.yml.erb"
    cookbook "app_passenger"
    owner node[:app][:user]
    group node[:app][:group]
    database db_name
    driver_type "ruby"
    vars(
      :environment => node[:app_passenger][:project][:environment]
    )
  end

  # Creating bash file for manual $RAILS_ENV setup
  log "  Creating bash file for manual $RAILS_ENV setup"
  template "/etc/profile.d/rails_env.sh" do
    mode '0744'
    source "rails_env.erb"
    cookbook 'app_passenger'
    variables(
      :environment => node[:app_passenger][:project][:environment]
    )
  end

end


# Downloads/Updates application repository
action :code_update do
  deploy_dir = new_resource.destination

  log "  Starting code update sequence"
  log "  Current project doc root is set to #{deploy_dir}"

  log "  Starting source code download sequence..."
  # Calling "repo" LWRP to download remote project repository
  # See cookbooks/repo/resources/default.rb for the "repo" resource.
  repo "default" do
    destination deploy_dir
    action node[:repo][:default][:perform_action].to_sym
    app_user node[:app][:user]
    environment "RAILS_ENV" => "#{node[:app_passenger][:project][:environment]}"
    repository node[:repo][:default][:repository]
    persist false
  end

  # Moving rails application log directory to ephemeral

  # Removing log directory, preparing to symlink
  directory "#{deploy_dir}/log" do
    action :delete
    recursive true
  end

  # Creating new rails application log  directory on ephemeral volume
  directory "/mnt/ephemeral/log/rails/#{node[:web_apache][:application_name]}" do
    owner node[:app][:user]
    mode "0755"
    action :create
    recursive true
  end

  # Symlinking application log directory to ephemeral volume
  link "#{deploy_dir}/log" do
    to "/mnt/ephemeral/log/rails/#{node[:web_apache][:application_name]}"
  end

  # Sets permissions for the code to be owned by the application user.
  bash "chown_home" do
    flags "-ex"
    code "chown -R #{node[:app][:user]}:#{node[:app][:group]} #{deploy_dir}"
  end

  log "  Generating new logrotate config for rails application"
  # See cookbooks/rightscale/definitions/rightscale_logrotate_app.rb for the "rightscale_logrotate_app" definition.
  rightscale_logrotate_app "rails" do
    cookbook "rightscale"
    template "logrotate.erb"
    path ["#{deploy_dir}/log/*.log"]
    frequency "size 10M"
    rotate 4
    create "660 #{node[:app][:user]} #{node[:app][:group]}"
  end

end


# Sets up monitoring tools for passenger
action :setup_monitoring do
  plugin_path = "#{node[:rightscale][:collectd_lib]}/plugins/passenger"

  service "collectd" do
    action :enable
  end

  directory "#{node[:rightscale][:collectd_lib]}/plugins/" do
    recursive true
    not_if { ::File.exists?("#{node[:rightscale][:collectd_lib]}/plugins/") }
  end

  # Installing collectd plugin for passenger monitoring
  template "#{plugin_path}" do
    source "collectd_passenger.erb"
    mode "0755"
    backup false
    cookbook "app_passenger"
    variables(
      :apache_binary => node[:apache][:binary],
      :passenger_memory_stats => "#{node[:app_passenger][:passenger_bin_dir]}/passenger-memory-stats",
      :passenger_status => "#{node[:app_passenger][:passenger_bin_dir]}/passenger-status"
    )
    notifies :restart, resources(:service => "collectd")
  end

  # Removing previous passenger.conf in case of stop-start
  file "#{node[:rightscale][:collectd_plugin_dir]}/passenger.conf" do
    backup false
    action :delete
  end

  # Installing collectd config for passenger plugin
  template "#{node[:rightscale][:collectd_plugin_dir]}/passenger.conf" do
    cookbook "app_passenger"
    source "collectd_passenger.conf.erb"
    variables(
      :apache_executable => node[:web_apache][:config_subdir],
      :apache_user => node[:app][:user],
      :plugin_path => plugin_path
    )
    notifies :restart, resources(:service => "collectd")
  end

  # Collectd exec cannot run scripts under root user, so we need to give ability to use sudo to "apache" user
  # passenger monitoring resources have strict restrictions, only for root can gather full stat info
  # we gave permissions to apache user to access passenger monitoring resources
  ruby_block "sudo setup" do
    block { ::File.open('/etc/sudoers', 'a') { |file| file.puts "#includedir /etc/sudoers.d\n" } }
    not_if { ::File.readlines("/etc/sudoers").grep(/^\s*#includedir\s+\/etc\/sudoers.d/).any? }
  end

  directory "/etc/sudoers.d/" do
    recursive true
  end

  template "/etc/sudoers.d/passenger-status" do
    cookbook "app_passenger"
    source "passenger-status.erb"
    mode "0440"
    variables(
      :user => node[:app][:user],
      :passenger_bin_dir => node[:app_passenger][:passenger_bin_dir]
    )
    not_if { ::File.exists?("/etc/sudoers.d/passenger-status") }
    notifies :restart, resources(:service => "collectd")
  end

end
