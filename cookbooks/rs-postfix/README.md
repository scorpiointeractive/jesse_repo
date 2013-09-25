# RightScale Postfix Wrapper Cookbook

## DESCRIPTION:

Wrapper cookbook using opscode community cookbook, 'postfix'.

## REQUIREMENTS:

* 'postfix' opscode community cookbook
* Ability to send outgoing traffic to port 25.

## KNOWN LIMITATIONS:

There are no known limitations.

## USAGE:

Only the `setup_local_delivery` recipe is used.  It allows the sending of 
local mail by accepting SMTP connections on localhost.

## LICENSE:

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
