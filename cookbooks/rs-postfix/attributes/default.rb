#
# Cookbook Name:: rs-postfix
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

set['postfix']['inet_interfaces'] = "all"
set['postfix']['mail_type'] = "master"
