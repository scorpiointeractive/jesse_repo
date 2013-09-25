#
# Cookbook Name:: web_apache_multiapp
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

# Calls the cookbooks/web_apache_multiapp/recipes/install_apache.rb recipe.
include_recipe "web_apache_multiapp::install_apache"
