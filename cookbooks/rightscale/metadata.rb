maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Base recipes used to set up services used by the RightScale" +
                 " Cloud Management Platform."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

supports "centos"
supports "redhat"
supports "ubuntu"

depends "driveclient"
depends "cloudmonitoring"

recipe "rightscale::default",
  "Installs the utilities that are required for RightScale support."

recipe "rightscale::setup_monitoring",
  "Installs and configures RightScale dashboard monitoring features."

recipe "rightscale::setup_ssh",
  "Installs the private ssh key."

recipe "rightscale::setup_hostname",
  "Sets the system hostname."

recipe "rightscale::setup_timezone",
  "Sets the system timezone."

recipe "rightscale::setup_server_tags",
  "Sets machine tags that are common to all RightScale managed servers."

recipe "rightscale::setup_cloud",
  "Sets up cloud specific functions."

recipe "rightscale::install_tools",
  "Installs RightScale's instance tools."

recipe "rightscale::install_mysql_collectd_plugin",
  "Installs the mysql collectd plugin for monitoring support."

recipe "rightscale::install_file_stats_collectd_plugin",
  "Installs the file-stats.rb collectd plugin for monitoring support." +
  " It is also used for mysql binary backup alerting."

recipe "rightscale::do_security_updates",
  "Do a system package update to pull in the latest security patches."

recipe "rightscale::setup_security_updates",
  "Sets up package manager software for security updates."

recipe "rightscale::setup_security_update_monitoring",
  "Sets up collectd plugin to monitor for available security updates."

recipe "rightscale::install_rightimage_extras",
  "Installs the RightImage extra packages expected by our ServerTemplates."

recipe "rightscale::setup_redhat",
  "Registers a system with the Red Hat Network Classic."

attribute "rightscale/security_updates",
  :display_name => "Enable security updates",
  :description => "Unfreezes software repositories after booting and" +
    " installing packages, allowing for security updates to be installed.",
  :required => "optional",
  :choice => [ "enable", "disable" ],
  :default => "disable",
  :recipes => [
    "rightscale::do_security_updates",
    "rightscale::setup_security_updates",
    "rightscale::setup_security_update_monitoring"
  ]

attribute "rightscale/timezone",
  :display_name => "Timezone",
  :description =>
    "Sets the system time to the timezone of the specified input," +
    " which must be a valid zoneinfo/tz database entry." +
    " If the input is 'unset' the timezone will use the 'localtime'" +
    " that's defined in your RightScale account" +
    " under Settings -> User Settings -> Preferences tab." +
    " You can find a list of valid examples from the timezone pulldown bar" +
    " in the Preferences tab. Example: US/Pacific",
  :required => "optional",
  :choice => [
    "Africa/Casablanca",
    "America/Bogota",
    "America/Buenos_Aires",
    "America/Caracas",
    "America/La_Paz",
    "America/Lima",
    "America/Mexico_City",
    "Asia/Almaty",
    "Asia/Baghdad",
    "Asia/Baku",
    "Asia/Bangkok",
    "Asia/Calcutta",
    "Asia/Colombo",
    "Asia/Dhaka",
    "Asia/Hong_Kong",
    "Asia/Jakarta",
    "Asia/Kabul",
    "Asia/Kamchatka",
    "Asia/Karachi",
    "Asia/Kathmandu",
    "Asia/Magadan",
    "Asia/Muscat",
    "Asia/Riyadh",
    "Asia/Seoul",
    "Asia/Singapore",
    "Asia/Tashkent",
    "Asia/Tbilisi",
    "Asia/Tehran",
    "Asia/Tokyo",
    "Asia/Vladivostok",
    "Asia/Yakutsk",
    "Asia/Yekaterinburg",
    "Atlantic/Azores",
    "Atlantic/Cape_Verde",
    "Australia/Adelaide",
    "Australia/Darwin",
    "Australia/Perth",
    "Brazil/Acre",
    "Brazil/DeNoronha",
    "Brazil/East",
    "Brazil/West",
    "Canada/Atlantic",
    "Canada/Newfoundland",
    "Europe/Brussels",
    "Europe/Copenhagen",
    "Europe/Kaliningrad",
    "Europe/Lisbon",
    "Europe/London",
    "Europe/Helsinki",
    "Europe/Madrid",
    "Europe/Moscow",
    "Europe/Paris",
    "Pacific/Auckland",
    "Pacific/Fiji",
    "Pacific/Guam",
    "Pacific/Kwajalein",
    "Pacific/Midway",
    "US/Alaska",
    "US/Central",
    "US/Eastern",
    "US/Hawaii",
    "US/Mountain",
    "US/Pacific",
    "US/Samoa",
    "GMT",
    "UTC",
    "localtime"
  ],
  :default => "UTC",
  :recipes => [
    "rightscale::setup_timezone",
    "rightscale::default"
  ]

attribute "rightscale/process_list",
  :display_name => "Process List",
  :description =>
    "A space-separated list of additional processes to monitor" +
    " in the RightScale Dashboard. Example: sshd crond",
  :required => "optional",
  :default => "",
  :recipes => [
    "rightscale::install_mysql_collectd_plugin",
    "rightscale::setup_monitoring",
    "rightscale::default"
  ]

attribute "rightscale/process_match_list",
  :display_name => "Process Match List",
  :description =>
    "A space-separated list of pairs used to match the name(s)" +
    " of additional processes to monitor in the RightScale Dashboard." +
    " Paired arguments are passed in using the following syntax 'name/regex'." +
    " Example: ssh/ssh* cron/cron*",
  :required => "optional",
  :default => "",
  :recipes => [
    "rightscale::install_mysql_collectd_plugin",
    "rightscale::setup_monitoring",
    "rightscale::default"
  ]

attribute "rightscale/private_ssh_key",
  :display_name => "Private SSH Key",
  :description =>
    "The private SSH key of another instance that gets installed on this" +
    " instance. Select input type 'key' from the dropdown" +
    " and then select an SSH key that is installed on the other instance." +
    " Example: key:my_key",
  :required => "required",
  :recipes => [
    "rightscale::setup_ssh"
  ]

attribute "rightscale/short_hostname",
  :display_name => "Short Hostname",
  :description =>
    "The short hostname that you would like this node to have." +
    " Example: myhost",
  :required => "required",
  :recipes => [
    "rightscale::setup_hostname"
  ]

attribute "rightscale/domain_name",
  :display_name => "Domain Name",
  :description =>
    "The domain name that you would like this node to have." +
    " Example: example.com",
  :required => "optional",
  :default => "",
  :recipes => [
    "rightscale::setup_hostname"
  ]

attribute "rightscale/search_suffix",
  :display_name => "Domain Search Suffix",
  :description =>
    "The domain search suffix you would like this node to have." +
    " Example: example.com",
  :required => "optional",
  :default => "",
  :recipes => [
    "rightscale::setup_hostname"
  ]

attribute "rightscale/rackspace_username",
  :display_name => "Rackspace Username",
  :description =>
    "The username for Rackspace cloud account. This is required for" +
    " registering instances with Rackspace Managed Cloud.",
  :required => "optional",
  :default => "",
  :recipes => [
    "rightscale::default",
    "rightscale::setup_cloud"
  ]

attribute "rightscale/rackspace_api_key",
  :display_name => "Rackspace API Key",
  :description =>
    "The API Key for Rackspace cloud account. This is required for" +
    " registering instances with Rackspace Managed Cloud.",
  :required => "optional",
  :default => "",
  :recipes => [
    "rightscale::default",
    "rightscale::setup_cloud"
  ]

attribute "rightscale/rackspace_tenant_id",
  :display_name => "Rackspace Tenant ID",
  :description =>
    "The tenant ID for Rackspace cloud account. This is required for" +
    " registering instances with Rackspace Managed Cloud.",
  :required => "optional",
  :default => "",
  :recipes => [
    "rightscale::default",
    "rightscale::setup_cloud"
  ]

attribute "rightscale/redhat/username",
  :display_name => "RedHat Network Username",
  :description =>
    "The username to register the system with under RHN Satellite or Red Hat" +
    " Network Classic. Example: cred:REDHAT_SUBSCRIBER_USERNAME",
  :required => "optional",
  :default => "",
  :recipes => [
    "rightscale::default",
    "rightscale::setup_redhat"
  ]

attribute "rightscale/redhat/password",
  :display_name => "RedHat Network Password",
  :description =>
    "The password associated with the username specified in the" +
    " rightscale/redhat/username input." +
    " Example: cred:REDHAT_SUBSCRIBER_PASSWORD",
  :required => "optional",
  :default => "",
  :recipes => [
    "rightscale::default",
    "rightscale::setup_redhat"
  ]

# RightScale ENV attributes.
#
# Maps each env:RS_* input a node[:rightscale][] equivalent.
# DO NOT CHANGE THESE inputs unless you know what you are doing.
# Doing so may break dashboard monitoring and cookbook recipes.
attribute "rightscale",
  :display_name => "RightScale Attributes",
  :type => "hash"

# These inputs are set by the core site and can not be set via the metadata.
# They are still valid and can be used the same way other node variables are set.
# They are included here for documentation purposes.
# Do not delete the commented out code.
#
# This list may change so care must be taken when adding
# or changing node[:rightscale] attributes.
# Doing so may break ServerTemplate functionality.

#attribute "rightscale/instance_uuid",
#  :display_name => "Instance UUID",
#  :description =>
#    "This is a place holder",
#  :required => "required",
#  :type => "env",
#  :choices => ["RS_INSTANCE_UUID"],
#  :default => "RS_INSTANCE_UUID",
#  :recipes => [ "rightscale::default" ]

#attribute "rightscale/servers/sketchy/hostname",
#  :display_name => "Sketchy Server",
#  :description =>
#    "This is a place holder",
#  :required => "required",
#  :type => "env",
#  :choices => ["RS_SKETCHY"],
#  :default => "RS_SKETCHY",
#  :recipes => [ "rightscale::default" ]

#attribute "rightscale/servers/sketchy/identifier"
#  :display_name => "Sketchy Identifier",
#  :required => "required",
#  :type => "env",
#  :choices => ["RS_INSTANCE_UUID"],
#  :default => "RS_INSTANCE_UUID",
#  :recipes => [ "rightscale::default" ]

