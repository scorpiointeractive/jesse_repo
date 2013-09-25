# require
require 'rubygems'
require 'json'

rightscale_marker

#Fetch application config data from RightScale Inputs
data = JSON.parse(node[:app_php_multiapp][:apps_json]);

data['sites'].each do |site|
	repo_name = site['name']
	deploy_dir = repo_name
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
end
