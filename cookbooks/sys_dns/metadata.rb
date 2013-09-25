maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "This cookbook provides a set of dynamic DNS recipes used by" +
                 " RightScale ServerTemplates including Database Manager" +
                 " ServerTemplates. Cookbook currently supports DNSMadeEasy," +
                 " DynDns, CloudDNS, and Amazon Route53 DNS service providers."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

supports "centos"
supports "redhat"
supports "ubuntu"

depends "rightscale"

recipe "sys_dns::default",
  "Installs tools needed by chosen DNS provider."

recipe "sys_dns::do_set_private",
  "Sets the dynamic DNS entry to the first private IP of the server."

recipe "sys_dns::do_set_public",
  "Sets the dynamic DNS entry to the first public IP of the server."

attribute "sys_dns/choice",
  :display_name => "DNS Service Provider",
  :description =>
    "The name of your DNS provider. Select the DNS provider" +
    " that you're using to manage the DNS A records of your master/slave" +
    " database servers (e.g., DNSMadeEasy, DynDNS, Route53, CloudDNS)." +
    " Note: You must specify the region when using Cloud DNS." +
    " Example: DNSMadeEasy ",
  :required => "required",
  :choice => ["DNSMadeEasy", "DynDNS", "Route53", "CloudDNS"],
  :recipes => [
    "sys_dns::do_set_private",
    "sys_dns::do_set_public",
    "sys_dns::default"
  ]

attribute "sys_dns/id",
  :display_name => "DNS Record ID",
  :description =>
    "The unique identifier that is associated with the DNS A record" +
    " of the server. The unique identifier is assigned by the DNS provider" +
    " when you create a dynamic DNS A record. This ID is used to update" +
    " the associated A record with the private IP address of the server" +
    " when this recipe is run. If you are using DNS Made Easy as" +
    " your DNS provider, a 7-digit number is used (e.g., 4403234)." +
    " If you are using Cloud DNS, provide both Domain ID and Record ID" +
    " (e.g., DomainID:A-RecordID). Example: 111021",
  :required => "required",
  :recipes => ["sys_dns::do_set_private", "sys_dns::do_set_public"]

attribute "sys_dns/user",
  :display_name => "DNS User",
  :description =>
    "The username that is used to access and modify the DNS A records." +
    " For DNS Made Easy and DynDNS, enter your user name" +
    " (e.g., cred:DNS_USER). For Amazon DNS, enter your Amazon access key ID" +
    " (e.g., cred:AWS_ACCESS_KEY_ID). For CloudDNS, enter your login username" +
    " (e.g., cred:RACKSPACE_USERNAME). Example: cred:CLOUD_ACCOUNT_USERNAME",
  :required => "required",
  :recipes => [
    "sys_dns::do_set_private",
    "sys_dns::do_set_public",
    "sys_dns::default"
  ]

attribute "sys_dns/password",
  :display_name => "DNS Password",
  :description =>
    "The password that is used to access and modify the DNS A Records." +
    " For DNS Made Easy and DynDNS, enter your password" +
    " (e.g., cred:DNS_PASSWORD). For Amazon DNS, enter your AWS secret" +
    " access key (e.g., cred:AWS_SECRET_ACCESS_KEY). For CloudDNS," +
    " enter your API key (e.g., cred:RACKSPACE_AUTH_KEY)." +
    " Example: cred:CLOUD_ACCOUNT_KEY ",
  :required => "required",
  :recipes => [
    "sys_dns::do_set_private",
    "sys_dns::do_set_public",
    "sys_dns::default"
  ]

attribute "sys_dns/region",
  :display_name => "Cloud DNS region",
  :description =>
    "You must specify the region when using CloudDNS." +
    " Example: Chicago",
  :required => "optional",
  :choice => ["Chicago", "Dallas", "London"],
  :recipes => [
    "sys_dns::do_set_private",
    "sys_dns::do_set_public",
    "sys_dns::default"
  ]
