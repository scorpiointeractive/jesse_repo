maintainer       "Scorpio Media"
maintainer_email "jesse@scorp.io"
license          "Copyright Scorpio Media. All rights reserved."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

supports "centos"
supports "redhat"
supports "ubuntu"

recipe "scorpio_defaults::set_defaults",
  " Sets common node attributes"

attribute "scorpio_defaults/apps_json",
  :display_name => "JSON Application config data",
  :description => "Hosts the server name, aliases, ssl info, and SVN info" + 
					" for multiple web applications. The format is as follows: " +
					"{\"sites\":[{\"name\":\"example.com\", \"aliases\":[\"ex.am.pl\"," +
					"\"ex.ample.com\"], \"ssl_cert\"=\"<SSL cert contents>\"," +
					"\"ssl_key\"=\"<SSL key contents>\"," +
					"\"ssl_chain\"=\"<SSL chain contents>\", \"svn_remote_repo\":" +
					"\https://svn.myrepo.com/project/\"}]} of multiple sites/applications." +
					" Aliases and ssl are optional.",
  :default => '{
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
   }',
  :recipes => ["scorpio_defaults::set_defaults"]

attribute "scorpio_defaults/storage_provider",
  :display_name => "Cloud Storage Account Provider",
  :description =>
    "The cloud storage provider." +
    " (complete list of supported storage locations is in input dropdown)." +
    " Example: google",
  :required => "required",
  :choice => [
    "s3",
    "Cloud_Files",
    "Cloud_Files_UK",
    "google",
    "azure",
    "swift",
    "SoftLayer_Dallas",
    "SoftLayer_Singapore",
    "SoftLayer_Amsterdam"
  ],
  :recipes => ["scorpio_defaults::set_defaults"]

attribute "scorpio_defaults/storage_container",
  :display_name => "Cloud Storage Bucket or Container",
  :description =>
    "The cloud storage provider container and/or bucket." +
    " For Amazon S3, use the bucket name." +
    " For Rackspace Cloud Files, use the container name." +
    " Example: scorpio-media",
  :required => "required",
  :recipes => ["scorpio_defaults::set_defaults"]

attribute "scorpio_defaults/storage_accnt_id",
  :display_name => "Cloud Storage Account ID",
  :description =>
    "In order to read and/or write to the specified cloud storage location," +
    " you need to provide cloud authentication credentials." +
    " For Amazon S3, use your Amazon access key ID" +
    " (e.g., cred:AWS_ACCESS_KEY_ID). For Rackspace Cloud Files, use your" +
    " Rackspace login username (e.g., cred:RACKSPACE_USERNAME)." +
    " For OpenStack Swift the format is: 'tenantID:username'." +
    " Example: cred:AWS_ACCESS_KEY_ID",
  :required => "required",
  :recipes => ["scorpio_defaults::set_defaults"]

attribute "scorpio_defaults/storage_accnt_secret",
  :display_name => "Cloud Storage Account Secret",
  :description =>
    "In order to read and/or write to the specified cloud storage location," +
    " you need to provide cloud authentication credentials." +
    " For Amazon S3, use your AWS secret access key" +
    " (e.g., cred:AWS_SECRET_ACCESS_KEY)." +
    " For Rackspace Cloud Files, use your Rackspace account API key" +
    " (e.g., cred:RACKSPACE_AUTH_KEY). Example: cred:AWS_SECRET_ACCESS_KEY",
  :required => "required",
  :recipes => ["scorpio_defaults::set_defaults"]

attribute "scorpio_defaults/svn_sync_backup_prefix",
  :display_name => "SVN Sync Backup Prefix",
  :description =>
    "The prefix that will be used to name/locate the backup" +
    " of Jesse SVN sync script and its associated files.",
  :required => "optional",
  :default => "SVN_SCRIPT_BACKUP",
  :recipes => ["scorpio_defaults::set_defaults"]

attribute "scorpio_defaults/mod_rpaf_backup_prefix",
  :display_name => "Apache mod_rpaf Backup Prefix",
  :description =>
    "The prefix that will be used to name/locate the backup" +
    " of Apache mod_rpaf.",
  :required => "optional",
  :default => "MOD_RPAF_BACKUP",
  :recipes => ["scorpio_defaults::set_defaults"]

attribute "scorpio_defaults/mod_cloudflare_backup_prefix",
  :display_name => "Apache mod_cloudflare Backup Prefix",
  :description =>
    "The prefix that will be used to name/locate the backup" +
    " of Apache mod_cloudflare.",
  :required => "optional",
  :default => "MOD_CLOUDFLARE_BACKUP",
  :recipes => ["scorpio_defaults::set_defaults"]

attribute "scorpio_defaults/cloudflare_user",
  :display_name => "CloudFlare User",
  :description =>
    "No description for now",
  :required => "required",
  :recipes => ["scorpio_defaults::set_defaults"]

attribute "scorpio_defaults/cloudflare_key",
  :display_name => "CloudFlare Key",
  :description =>
    "No description for now",
  :required => "required",
  :recipes => ["scorpio_defaults::set_defaults"]

attribute "scorpio_defaults/cloudflare_host",
  :display_name => "CloudFlare Host",
  :description =>
    "No description for now",
  :required => "required",
  :recipes => ["scorpio_defaults::set_defaults"]

attribute "scorpio_defaults/cloudflare_rec_name",
  :display_name => "CloudFlare DNS Record Name",
  :description =>
    "No description for now",
  :required => "required",
  :recipes => ["scorpio_defaults::set_defaults"]

attribute "scorpio_defaults/cloudflare_rec_ids",
  :display_name => "CloudFlare DNS Record IDs",
  :description =>
    "No description for now",
  :required => "required",
  :recipes => ["scorpio_defaults::set_defaults"]

attribute "scorpio_defaults/rs_email",
  :display_name => "Rigthscale Email",
  :description =>
    "No description for now",
  :required => "required",
  :recipes => ["scorpio_defaults::set_defaults"]

attribute "scorpio_defaults/rs_pswd",
  :display_name => "Rigthscale Password",
  :description =>
    "No description for now",
  :required => "required",
  :recipes => ["scorpio_defaults::set_defaults"]

attribute "scorpio_defaults/rs_pswd",
  :display_name => "Rigthscale Password",
  :description =>
    "No description for now",
  :required => "required",
  :recipes => ["scorpio_defaults::set_defaults"]

attribute "scorpio_defaults/rs_id",
  :display_name => "Rigthscale ID",
  :description =>
    "No description for now",
  :required => "required",
  :recipes => ["scorpio_defaults::set_defaults"]

attribute "scorpio_defaults/tag_search",
  :display_name => "Instance Search Tag",
  :description =>
    "No description for now",
  :required => "required",
  :recipes => ["scorpio_defaults::set_defaults"]

attribute "scorpio_defaults/site_name",
  :display_name => "Site Name",
  :description =>
    "No description for now",
  :required => "required",
  :recipes => ["scorpio_defaults::set_defaults"]

attribute "scorpio_defaults/chk_url",
  :display_name => "Url to check",
  :description =>
    "No description for now",
  :required => "required",
  :recipes => ["scorpio_defaults::set_defaults"]

