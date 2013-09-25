rightscale_marker

require 'rubygems'
require 'json'

# Installing only for RHEL based systems
# Commented. Already defined in web_apache_multiapp/recipes/install_apache.rb
#package "mod_ssl" do
#  not_if { node[:platform].include? "ubuntu" }
#end

# Setup Apache vhost on following ports
https_port = "443"
http_port = "80"

# Disable default vhost.
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

# Fetch application config data from RightScale Inputs
data = JSON.parse(node[:web_apache_multiapp][:apps_json]);

# Build Apache config for each site in config data
data['sites'].each do |site|

	server_name = site['name']
	server_aliases_line = ''
	#docroot = "/home/webapps/#{server_name}"
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
	
        log "  #{server_name}: HAS SSL" if using_ssl
        log "  #{server_name}: NO SSL" if not using_ssl

	# Set SSL chain if in configuration
	if site.has_key?('ssl_chain') && !site['ssl_chain'].empty?
		ssl_chain = site['ssl_chain']
	end
	
	#######Modified From RightScale########
	ssl_certificate_file = ::File.join(ssl_dir, "#{server_name}.crt")
	ssl_key_file = ::File.join(ssl_dir, "#{server_name}.key")

	# Updating crt file config
	template ssl_certificate_file do
	  mode "0400"
	  source "ssl_certificate.erb"
	  variables(
		:ssl_certificate => ssl_cert
	  )
	  only_if { using_ssl }
	end

	# Updating key file config
	template ssl_key_file do
	  mode "0400"
	  source "ssl_key.erb"
	  variables(
		:ssl_key => ssl_key
	  )
	  only_if { using_ssl }
	end










	# Optional certificate chain
	if ssl_chain
	  log "  Using SSL certificate chain"
	  ssl_certificate_chain_file = ::File.join(ssl_dir, "#{server_name}.sf_crt")
	  template "#{ssl_certificate_chain_file}" do
		mode "0400"
		source "ssl_certificate_chain.erb"
		variables(
		  :ssl_certificate_chain => ssl_chain
		)
	  end
	else
	  ssl_certificate_chain_file = nil
	end

	node[:apache][:listen_ports].push(http_port) unless node[:apache][:listen_ports].include?(http_port)
	node[:apache][:listen_ports].push(https_port) unless node[:apache][:listen_ports].include?(https_port)

	# Updating apache listen ports configuration
	template "#{node[:apache][:dir]}/ports.conf" do
	  cookbook "apache2"
	  source "ports.conf.erb"
	  variables :apache_listen_ports => node[:apache][:listen_ports]
	  notifies :restart, resources(:service => "apache2")
	end

	# Configure apache ssl vhost
	# See https://github.com/rightscale/cookbooks/blob/master/apache2/definitions/web_app.rb for the "web_app" definition.
        if using_ssl
  	  web_app "#{server_name}.frontend.https" do
	    template "apache_ssl_vhost.erb"
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
	  template "apache.conf.erb"
	  docroot docroot
	  vhost_port http_port
	  server_name server_name
	  server_aliases_line server_aliases_line
	  allow_override node[:web_apache_multiapp][:allow_override]
	  apache_log_dir node[:apache][:log_dir]
	  notifies :restart, resources(:service => "apache2"), :immediately
	end
	#######End Modified Section#######
end
