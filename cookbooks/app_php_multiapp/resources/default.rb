#
# Cookbook Name:: app_php_multiapp
#


actions :update_rpaf

# Sets regex for identifying machine tags in servers on which remote_recieps can
# be run
attribute :machine_tag, :kind_of => String, :regex => /^([^:]+):(.+)=.+/

# Sets the IP interface on which the server listens. Example: public_ip_0, private_ip_0
attribute :ip_tag, :kind_of => String, :regex => /server:(.+)/

# Server collection
attribute :collection, :kind_of => String, :default => "mycollection"

# Defines a default action
def initialize(*args)
  super
  @action = :update_rpaf
end
