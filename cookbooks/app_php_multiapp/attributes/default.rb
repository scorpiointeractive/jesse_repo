#
# Cookbook Name:: app_php_multiapp
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Recommended attributes

# List of additional php modules
default[:app_php_multiapp][:modules_list] = []
# List of required apache modules
default[:app_php_multiapp][:module_dependencies] = []
