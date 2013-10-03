#
# Cookbook Name:: app_php_multiapp
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# @resource app

# require
require 'rubygems'
require 'json'
require "timeout"

# Stops apache
action :stop do
  log "  Running stop sequence"
  service "apache2" do
    action :stop
    persist false
  end
end

# Starts apache
action :start do
  log "  Running start sequence"
  service "apache2" do
    action :start
    persist false
  end
end

# Reloads apache
action :reload do
  log "  Running reload sequence"
  service "apache2" do
    action :reload
    persist false
  end
end

# Restarts apache
action :restart do
  # Calls the :stop action.
  action_stop
  sleep 5
  # Calls the :start action.
  action_start
end

# Installs packages and modules required for PHP application server.
action :install do
  # Installing required packages
  packages = new_resource.packages

  unless packages.nil?
    log "  Packages which will be installed #{packages}"

    packages.each do |p|
      package p
    end
  end

  # Installing user-specified additional php modules
  log "  Modules which will be installed: #{node[:app_php_multiapp][:modules_list]}"
  node[:app_php_multiapp][:modules_list].each do |p|
    package p
  end

  log "  Module dependencies which will be installed:" +
    " #{node[:app_php_multiapp][:module_dependencies]}"
  # Installing php modules dependencies
  node[:app_php_multiapp][:module_dependencies].each do |mod|
    # See https://github.com/rightscale/cookbooks/blob/master/apache2/definitions/apache_module.rb
    # for the "apache_module" definition.
    apache_module mod
  end
  
  # install pear packages
  execute "install pear mail" do
    command "pear install mail"
    action :run
  end

  execute "install pear mail_mime" do
    command "pear install mail_mime"
    action :run
  end

  execute "install pear config_lite" do
    command "pear install Config_Lite channel://pear.php.net/Config_Lite-0.1.5"
    action :run
  end

  execute "install pear net_smtp" do
    command "pear install net_smtp"
    action :run
  end
end


# Sets up apache PHP virtual host
action :setup_vhost do

  # Setup Apache vhost on following ports
  https_port = "8001"
  http_port = "8000"

  # Disable default vhost
  # See https://github.com/rightscale/cookbooks/blob/master/apache2/definitions/apache_site.rb for the "apache_site" definition.
  apache_site "000-default" do
    enable false
  end
  
  ssl_dir = "/etc/#{node[:web_apache_multiapp][:config_subdir]}/rightscale.d/key"

  # Creating directory where certificate files will be stored
  directory ssl_dir do
    mode "0700"
    recursive true
  end

  # Adds php port to list of ports for webserver to listen on
  # See cookbooks/app/definitions/app_add_listen_port.rb for the "app_add_listen_port" definition.
  app_add_listen_port https_port
  app_add_listen_port http_port

  data = JSON.parse(node[:app_php_multiapp][:apps_json]);
  
  data['sites'].each do |site|
	server_name = site['name']
	server_aliases_line = ''
	docroot = "#{node[:web_apache_multiapp][:docroot]}/#{server_name}"

	# Build aliases
	if site.has_key?('aliases') && site['aliases'].length > 0
	  server_aliases_line = 'ServerAlias'
	  site['aliases'].each do |single_alias|
	    server_aliases_line << " #{single_alias}"
	  end
	end
    
	# Build SSL config
	using_ssl = false
	ssl_chain = nil
	if site.has_key?('ssl_cert') && site.has_key?('ssl_key') && !site['ssl_cert'].empty? && !site['ssl_key'].empty?
	  ssl_cert = site['ssl_cert']
	  ssl_key = site['ssl_key']
	  using_ssl = true
	end
	
	# Set SSL chain if in configuration
	if site.has_key?('ssl_chain') && !site['ssl_chain'].empty?
	  ssl_chain = site['ssl_chain']
	end
	
	ssl_certificate_file = ::File.join(ssl_dir, "#{server_name}.crt")
	ssl_key_file = ::File.join(ssl_dir, "#{server_name}.key")
	
	template ssl_certificate_file do
	  mode "0400"
	  cookbook "web_apache_multiapp"
	  source "ssl_certificate.erb"
	  variables(
	    :ssl_certificate => ssl_cert
	  )
	  only_if { using_ssl }
	end
	
	template ssl_key_file do
	  mode "0400"
	  cookbook "web_apache_multiapp"
	  source "ssl_key.erb"
	  variables(
		:ssl_key => ssl_key
	  )
	  only_if { using_ssl }
	end
	
	if ssl_chain
	  log "  Using SSL certificate chain"
	  ssl_certificate_chain_file = ::File.join(ssl_dir, "#{server_name}.sf_crt")
	  template "#{ssl_certificate_chain_file}" do
		mode "0400"
		cookbook "web_apache_multiapp"
		source "ssl_certificate_chain.erb"
		variables(
		  :ssl_certificate_chain => ssl_chain
		)
	  end
	else
	  ssl_certificate_chain_file = nil
	end
	
	# Configure apache ssl vhost
	# See https://github.com/rightscale/cookbooks/blob/master/apache2/definitions/web_app.rb for the "web_app" definition.
        if using_ssl 
   	  web_app "#{server_name}.frontend.https" do
            cookbook "app_php_multiapp"
	    template "app_server_https.erb"
	    docroot docroot
	    vhost_port https_port
	    server_name server_name
	    server_aliases_line server_aliases_line
	    ssl_certificate_chain_file ssl_certificate_chain_file
	    ssl_certificate_file ssl_certificate_file
	    ssl_key_file ssl_key_file
	    allow_override node[:web_apache_multiapp][:allow_override]
	    apache_log_dir node[:apache][:log_dir]
	    notifies :restart, resources(:service => "apache2")
	  end
	end

	# Configure apache non-ssl vhost
	web_app "#{server_name}.frontend.http" do
          cookbook "app_php_multiapp"
	  template "app_server.erb"
	  docroot docroot
	  vhost_port http_port
	  server_name server_name
	  server_aliases_line server_aliases_line
	  allow_override node[:web_apache_multiapp][:allow_override]
	  apache_log_dir node[:apache][:log_dir]
	  notifies :restart, resources(:service => "apache2"), :immediately
	end
  end
end

# Sets up PHP Database Connection
action :setup_db_connection do
  project_root = new_resource.destination
  db_name = new_resource.database_name
  # Make sure config dir exists
  directory ::File.join(project_root, "config") do
    recursive true
    owner node[:app][:user]
    group node[:app][:group]
  end

  # Tells selected db_adapter to fill in it's specific connection template
  # See cookbooks/db/definitions/db_connect_app.rb for the "db_connect_app" definition.
  db_connect_app ::File.join(project_root, "config", "db.php") do
    template "db.php.erb"
    cookbook "app_php_multiapp"
    database db_name
    owner node[:app][:user]
    group node[:app][:group]
    driver_type "php"
  end
end

# Downloads/Updates application repository
action :code_update do

  #Fetch application config data from RightScale Inputs
  data = JSON.parse(node[:app_php_multiapp][:apps_json]);


  data['sites'].each do |site|
    repo_name = site['name']
    deploy_dir = "#{node[:web_apache_multiapp][:docroot]}/#{repo_name}"

    directory deploy_dir do
      mode "0644"
      recursive true
    end

    repo_url = site['svn_repo_url']
    repo_user = site['svn_repo_user']
    repo_password = site['svn_repo_password']
    revision = 'HEAD'
    provider = 'repo_svn'
	
    log "  Starting code update sequence. Please wait..."
    log "  Current project doc root is set to #{deploy_dir}"
    log "  Downloading project repo from #{repo_url}."
    log "  Using SVN user #{repo_user}." 	

    # Calling "repo" LWRP to download remote project repository
    # See cookbooks/repo/resources/default.rb for the "repo" resource.
    repo "#{repo_name}" do
      provider provider
      repository repo_url
      revision revision
      account repo_user
      credential repo_password	   
      destination deploy_dir
      app_user node[:app][:user]
      action node[:repo][:default][:perform_action].to_sym
      persist false	   
    end

    log "  Changing directory permissions to apache user..."
    execute "change ownership to apache user" do
      command "chown -R #{node[:apache][:user]}.#{node[:apache][:group]} #{deploy_dir}"
      action :run 
    end
  end
end

# Sets up monitoring for PHP application server. Not implemented.
action :setup_monitoring do

  log "  Monitoring resource is not implemented in php framework yet. Use apache monitoring instead."

end

action :update_rpaf do
  machine_tag = new_resource.machine_tag
  ip_tag = new_resource.ip_tag

  # For backwards compatibility use the private ip tag if the ip_tag
  # was not passed
  ip_tag = "server:private_ip_0" unless ip_tag
  machine_tag "loadbalancer:default=lb"

  collection_name = new_resource.collection

  log "  Using machine tags #{machine_tag} and #{ip_tag} to determine" +
    " IP address." if machine_tag 

  if machine_tag
     # See cookbooks/rightscale/providers/server_collection.rb for 
     # the "rightscale_server_collection" resource.
     rightscale_server_collection collection_name do
       tags machine_tag
       mandatory_tags ip_tag
     end
  end

  ip_list = []

  if machine_tag
    valid_ip_regex =
       '\b(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}' +
       '([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\b'
    ip_list = node[:server_collection][collection_name].collect do |_, tags|
      # See cookbooks/rightscale/libraries/helper.rb for
      # the "get_tag_value" definition.
      RightScale::Utils::Helper.get_tag_value(ip_tag, tags, valid_ip_regex)
    end
  end

  rpaf_file = "/etc/httpd/mods-available/rpaf.conf"
  rpaf_proxy_ips = "RPAFproxy_ips 127.0.0.1"
 
  is_config_change = false
  old_config = File.readlines(rpaf_file)
   
  ip_list.each do |ip|
     regex = "/^RPAFProxy_ips/"
     matches = old_config.select { |line| line[/#{regex}/i] }
     matches.each do |line|
       if line =~ "/#{ip}/"
         
       else
         rpaf_proxy_ips = rpaf_proxy_ips << " " << ip
         is_config_change = true
         break    
       end
     end
  end

  log "  New RPAF Config: #{rpaf_proxy_ips}"

  #ruby_block "edit rpaf config" do
  #  block do
  #    file = Chef::Util::FileEdit.new(rpaf_file)
  #    file.search_file_replace_line("/RPAFproxy/", rpaf_proxy_ips)
  #    file.write_file
  #  end
  #end
  
  if platform_family?("debian", "ubuntu")
    service_name = "apache2" 
  else
    service_name = "httpd" 
  end

  bash "change rpaf config" do
   user "root"
   code <<-EOS
     sed -i '/RPAFproxy_ips/d' #{rpaf_file} &&
     echo #{rpaf_proxy_ips} >> #{rpaf_file} &&
     service #{service_name} restart 
   EOS
   only_if { is_config_change }
  end
end
