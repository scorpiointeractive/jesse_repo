#
# Cookbook Name:: scorpio_defaults
#

default[:scorpio_defaults][:storage_provider]		= "google"
default[:scorpio_defaults][:storage_container]		= "scorpio-media"
default[:scorpio_defaults][:storage_accnt_id]		= "my_account_id"
default[:scorpio_defaults][:storage_accnt_secret]	= "my_account_password"
default[:scorpio_defaults][:svn_sync_backup_prefix]	= "SVN_SCRIPT_BACKUP"
default[:scorpio_defaults][:svn_sync_directory]		= "/root/scripts/"
default[:scorpio_defaults][:svn_sync_run_directory]	= "/var/run/svnupdate2way"
default[:scorpio_defaults][:apps_json]			= '{
							      "sites":[
      							         {
         						            "name":"example.com",
          						            "aliases":[
                                                                       "www.example.com",
                                                                       "ex.am.pl"
                                                                    ],
                                                                    "ssl_cert":"BEGIN CERTIFICATE AAAAA END CERTIFICATE",
                                                                    "ssl_key":"BEGIN RSA PRIVATE KEY BBBBB END RSA PRIVATE KEY",
                                                                    "ssl_chain":"BEGIN CERTIFICATE CCCCC END CERTIFICATE",
                                                                    "svn_remote_repo":"https://subversion.assembla.com/svn/my-project/branches/production/"
                                                                 }
                                                              ]
                                                          }'

default[:scorpio_defaults][:mod_rpaf_backup_prefix]		= "MOD_RPAF_BACKUP"
default[:scorpio_defaults][:mod_cloudflare_backup_prefix]	= "MOD_CLOUDFLARE_BACKUP"

default[:scorpio_defaults][:cloudflare_key]		= ""
default[:scorpio_defaults][:cloudflare_user]		= ""
default[:scorpio_defaults][:cloudflare_host]		= ""
default[:scorpio_defaults][:cloudflare_rec_ids]		= ""
default[:scorpio_defaults][:cloudflare_rec_name]	= ""
default[:scorpio_defaults][:rs_email]			= ""
default[:scorpio_defaults][:rs_pswd]			= ""
default[:scorpio_defaults][:rs_id]			= ""
default[:scorpio_defaults][:tag_search]			= ""
default[:scorpio_defaults][:site_name]			= ""
default[:scorpio_defaults][:chk_url]			= ""		

