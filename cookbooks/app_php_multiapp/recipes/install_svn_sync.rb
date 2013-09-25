#
# Cookbook Name:: app_php_multiapp
#

# require
require 'rubygems'
require 'json'

rightscale_marker

log "  Setting SVN sync settings. Please wait..."
log "  Installing monit..."

package "monit" do
  action :install
end

service "monit" do
  supports :restart => true, :status => true, :start => true, :stop => true
  action :enable
end

directory "#{node[:scorpio_defaults][:svn_sync_directory]}" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

directory "#{node[:scorpio_defaults][:svn_sync_run_directory]}" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

log "  Downloading SVN Scripts from ROS..."

prefix 				= node[:scorpio_defaults][:svn_sync_backup_prefix]
storage_provider 		= node[:scorpio_defaults][:storage_provider]
storage_container 		= node[:scorpio_defaults][:storage_container]
src_filepath 			= node[:scorpio_defaults][:svn_sync_directory]
storage_accnt_id 		= node[:scorpio_defaults][:storage_accnt_id]
storage_accnt_secret 		= node[:scorpio_defaults][:storage_accnt_secret]
dumpfilepath_without_extension 	= src_filepath + prefix

command_to_execute = "/opt/rightscale/sandbox/bin/ros_util get" +
    " --cloud #{storage_provider} --container #{storage_container}" +
    " --dest #{dumpfilepath_without_extension}" +
    " --source #{prefix} --latest"

log  "Command to execute: #{command_to_execute}"

options = {}
	
environment_variables = {
  'STORAGE_ACCOUNT_ID' => storage_accnt_id,
  'STORAGE_ACCOUNT_SECRET' => storage_accnt_secret
}.merge(options)

execute "Download svn scripts from Remote Object Store" do
  command command_to_execute
  creates dumpfilepath_without_extension
  environment environment_variables
end

bash "extract svn scripts" do
  cwd src_filepath
  code <<-EOH
    tar xzvf #{::File.basename(dumpfilepath_without_extension)}
  EOH
end

# Delete the default svn config file.
ruby_block "Delete the local file" do
  block do
    require "fileutils"
    FileUtils.rm_f "/root/scripts/svn_twoway/config/conf.ini.php"
  end
end

log "  Compiling svn sync configurations..."
data = JSON.parse(node[:app_php_multiapp][:apps_json]);

data['sites'].each do |site|
  repo_name = site['name']
  repo_url = site['svn_repo_url']
  repo_user = site['svn_repo_user']
  repo_password = site['svn_repo_password']
  deploy_dir = "#{node[:web_apache_multiapp][:docroot]}/#{repo_name}"
  repo_header = "svn_#{repo_name}"

  bash "append svn config file for #{repo_name}" do
    code <<-EOH
      echo '[#{repo_header}]' >> /root/scripts/svn_twoway/config/conf.ini.php &&
      echo 'remote_repo = "#{repo_url}"' >> /root/scripts/svn_twoway/config/conf.ini.php &&
      echo 'local_repo = "#{deploy_dir}"' >> /root/scripts/svn_twoway/config/conf.ini.php &&
      echo 'cpanel_root_folder = "no"' >> /root/scripts/svn_twoway/config/conf.ini.php &&
      echo 'svn_username = "#{repo_user}"' >> /root/scripts/svn_twoway/config/conf.ini.php &&
      echo 'svn_password = "#{repo_password}"' >> /root/scripts/svn_twoway/config/conf.ini.php &&
      echo 'folder_owner = "#{node[:apache][:user]}"' >> /root/scripts/svn_twoway/config/conf.ini.php &&
      echo 'admin_email[0] = "jesse@scorp.io"' >> /root/scripts/svn_twoway/config/conf.ini.php &&
      echo 'do_svn_co = "no"' >> /root/scripts/svn_twoway/config/conf.ini.php &&
      echo "\n" >> /root/scripts/svn_twoway/config/conf.ini.php
    EOH
    not_if "grep -q #{repo_header} /root/scripts/svn_twoway/config/conf.ini.php"
  end  
end

template "/etc/monit.d/svnupdater.conf" do
  source "monit_svnupdater.erb"
  notifies :restart, resources(:service => "monit")
end  

# Delete the local file.
ruby_block "Delete the local file" do
  block do
    require "fileutils"
    FileUtils.rm_f dumpfilepath_without_extension
  end
end
