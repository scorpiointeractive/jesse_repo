# RightScale Block Device Cookbook

## DESCRIPTION:

This cookbook provides the building blocks for multi-cloud backup/restore
support. It leverages RightScale's 1.0 and 1.5 API for performing volume
management across multiple clouds.

## REQUIREMENTS:

* The block device tools depend on the `rightscale::install_tools`
  recipe.
* Requires a virtual machine launched from a RightScale-managed RightImage.

## COOKBOOKS DEPENDENCIES:

Please see `metadata.rb` file for the latest dependencies.

## KNOWN LIMITATIONS:

* Rackspace requires an instance size of 512MB or larger. An instance size of
  256MB is not supported. (w-3947)
* Multiple block devices are not supported on Rackspace.

## SETUP/USAGE:

### Getting started and taking the first backup:

1. Import the latest version of 'Storage Toolbox (Chef)' ServerTemplate into
   your RightScale account.
2. Set up a new deployment. Add a server into the deployment using the
   toolbox ServerTemplate and launch the server.
3. Once the server is operational consider it in a 'pristine state'. Nothing
   will happen other than installing the tools until you run an operational
   recipe. You can modify this behavior by cloning the ServerTemplate and
   changing the list of recipes to run on boot.
4. Run the "block_device::setup_block_device" recipe, which attaches
   storage based on the volume size and number of volumes you have specified.
   The storage is located in '/mnt/storage1' by default.
5. Add your data into /mnt/storage1.
6. Run the recipe "block_device::do_primary_backup". This recipe detects
   what cloud you are on and performs a backup to the local cloud persistence
   service.

### Continuous Backups with CRON:

1. Enable continuous backups by running the recipe
   "block_device::setup_continuous_backups". This sets up a cron job.
2. You can disable backups at any time by running the
   "block_device::do_disable_continuous_backups" recipe, which removes
   the cron job that was performing backups.

### Force Reset:

1. WARNING: The "block_device::do_force_reset" recipe detaches all storage
   related to your lineage and DESTROYS the volumes! You should only run
   this recipe if you want to restore your database to a pristine state
   and do not want to save any of its data. After running the
   "block_device::do_force_reset" recipe you can then run the
   "block_device::setup_block_device" or "block_device::do_restore" recipes.

### Restore:

1. Start from a pristine state (fresh launch of a new server or using a server
   that's been reset).
2. Run the "block_device::do_restore" recipe.

Mix and match recipes to get the right combination for your deployments.

### Delete Volumes and Terminate

1. Delete the attached volumes and terminate the server. Note: if this script
   is not used to terminate the server the volumes will persist.

### Set up ephemeral device

1. To set up ephemeral file systems on clouds supporting ephemeral devices,
   place the `block_device::setup_ephemeral` recipe in your runlist.
2. The file system type set up in the ephemeral device can be configured by
   setting the "Ephemeral File System Type" input. By default, this input is
   set to 'xfs'. NOTE: On RedHat images, this input is ignored and 'ext3' file
   system is installed by default (RedHat does not support the 'xfs' file system
   type).

## DETAILS:

Multiple block device support is controlled by the
`block_device/devices_to_use` input. It can be a comma-separated list of
device names or '*' to indicate all devices. By default, there are two available
block devices. Currently, in order to add more block devices you need to
override the cookbook. Instructions can be found at: [Increase the Number of
Block Devices][Guide]

[Guide]: http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/04-Developer/ServerTemplate_Development/08-Common_Development_Tasks/Increase_the_Number_of_Block_Devices

The volume nicknames are made unique by appending the RightScale instance's uuid
to the provided nickname input. In case of "stop/start" operation (supported by
instances launched with EBS images), the uuid of the first instance before the
"stop" operation is used.

## LICENSE:

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
