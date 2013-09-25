#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Definition designed to move any directory to ephemeral drive and create
# symlink to it
#
# @param location_on_ephemeral [String] path where the directory needs to be moved
# @param user [String] owner for the directory
# @param group [String] group for the directory
# @param move_content [Boolean] specifies if the directory must be moved
#
define :rightscale_move_to_ephemeral, :location_on_ephemeral => nil, :user => "root", :group => "root", :move_content => false do
  default_dir = params[:name]
  ephemeral_dir = "/mnt/ephemeral/#{params[:location_on_ephemeral]}"

 # Create physical directory holding the data.
  directory ephemeral_dir do
    action :create
    owner params[:user]
    group params[:group]
    recursive true
  end

  if params[:move_content]
    # If default_dir is not a link, move it's files to ephemeral_dir.
    bash " Moving content from #{default_dir} to #{ephemeral_dir}" do
      not_if { File.symlink?(default_dir) }
      flags "-ex"
      code <<-EOH
        mv #{default_dir}/* #{ephemeral_dir}
      EOH
    end
  end

  # Delete default directory
  directory default_dir do
    not_if { File.symlink?(default_dir) }
    recursive true
    action :delete
  end

  # Create symlink from ephemeral location to default directory
  link default_dir do
    to ephemeral_dir
  end

end
