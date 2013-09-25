#
# Cookbook Name:: db_postgres
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Recommended attributes
default[:db_postgres][:server_usage] = "dedicated" # or "shared"

# Optional attributes

# Port on which postgres listens. Used by app servers to connect.
default[:db_postgres][:port] = "5432"

default[:db_postgres][:tunable] = {}
