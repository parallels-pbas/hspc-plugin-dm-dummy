## Copyright (C) 1999-2012 Parallels IP Holdings GmbH and its affiliates.
## All rights reserved.
##
package HSPC::MT::Plugin::DM::Dummy::Constants;
use strict;

use base qw(Exporter);

use constant DM_DUMMY_ALWAYS_AVAILABLE => 1;
use constant DM_DUMMY_ALWAYS_OCCUPIED => 2;
use constant DM_DUMMY_USE_WHOIS => 3;
use constant DM_PLUGIN_DUMMY => 'Dummy';

our @EXPORT = qw(
	DM_PLUGIN_DUMMY
	DM_DUMMY_ALWAYS_AVAILABLE 
	DM_DUMMY_ALWAYS_OCCUPIED 
	DM_DUMMY_USE_WHOIS 
);

1;
