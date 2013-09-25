# RightScale Logging Cookbook

## DESCRIPTION:

This cookbook provides a set of recipes used by the RightScale
ServerTemplates to configure the logging service provider.

This cookbook configures the default logging provider installed on the image.
If a remote server is defined it will configure an instance to send its
log messages to the specified remote server based on its FQDN or IP address.
If a remote server is not defined, the default configuration is used, which
saves the log files locally on the instance.

## REQUIREMENTS:

* Must be used with a 'logging' provider in the cookbook path
* Requires a virtual machine launched from a RightScale-managed RightImage.

## COOKBOOKS DEPENDENCIES:

Please see `metadata.rb` file for the latest dependencies.

* `rightscale`
* `logging_rsyslog`
* `logging_syslog_ng`

## KNOWN LIMITATIONS:

* Currently only supports the logging provider installed on the image:
  rsyslog or syslog-ng
* Cookbook supports client configuration for a single remote server using
  several protocols.
* Requires customer maintained remote server for remote logging.

## SETUP:

* Place `logging::default` recipe into your runlist to setup the logging
  resource. When using a RightScale ServerTemplate, this will also automatically
  configure logging service provider (rsyslog/syslog-ng). If a remote server is
  specified the default  recipe will determine the logging provider installed
  (rsyslog/syslog-ng) and configure it for remote logging.
* To setup a logging server, place the following recipes in order to your
  runlist:

    logging_<provider>::setup_server
      sets up the logging provider.

    logging::install_server
      sets up generic server inputs and configures a logging server.

  For example: To set up and install an rsyslog logging server

    logging_rsyslog::setup_server
    logging::install_server

## USAGE:

1. Local Logging - Set the 'logging/remote_server' input to 'ignore' to use
   the default configuration installed.
2. Remote Logging - Set the 'logging/remote_server' input to the FQDN or IP of
   the designated remote logging server to adjust the default configuration to
   the remote logging configuration.
3. Transfer protocol - Set the 'logging/protocol' input to one of the listed
   options:
   1. UDP: the most generic and common-used option. UDP is the default logging
      protocol option.
   2. RELP: RELP stands for Reliable Event Logging Protocol.
      RELP ensures that no message is lost, not even when connections break and
      a peer becomes unavailable.
   3. RELP-secured: while using RELP to ensure a safe and loss-free transmission
      between two machines the traffic also gets encrypted with an SSL
      certificate the user should provide with the 'logging/certificate' input.
      As stunnel is configured with the "verify = 3" option the server would
      require and verify the client certificate against the locally installed
      certificate providing client authentication.

## DETAILS:

### General

The 'logging' interface is defined by a Lightweight Resource, which can be found
in the `resources/default.rb` file.

This cookbook is intended as a framework for logging providers. The current
implementation supports the minimum configuration for rsyslog and syslog-ng.

Note: This cookbook does not modify the installed logging provider.

For more information about Lightweight Resources and Providers (LWRPs), please
see: [Lightweight Resources and Providers][LWRP]

[LWRP]: http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/04-Developer/06-Development_Resources/Lightweight_Resources_and_Providers_(LWRP)

### Providers:

The current implementation does not support providers other than rsyslog and
syslog-ng.

### Custom Configuration:

By using an override cookbook the default configuration can be customized by
replacing the default configuration file template for the provider. For more
information, please see: [Override Chef Cookbooks][CCDG].

[CCDG]: http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/04-Developer/ServerTemplate_Development/08-Common_Development_Tasks/Override_Chef_Cookbooks

## LICENSE:

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
