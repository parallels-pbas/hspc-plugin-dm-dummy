#!/usr/bin/perl
use strict;

use HSPC::WebDB qw(is_table_exists is_column_exists select_run);

my @to_add = qw(lookup_mode_tr suppress_transfer);
if (is_table_exists(table => 'dm_plugin_config_dummy')){
	foreach my $col (@to_add){
		unless (is_column_exists(table => 'dm_plugin_config_dummy', column => $col)){
			select_run(qq|
				alter table 
				dm_plugin_config_dummy 
				add column $col TINYINT(1)
			|);
		}
	}
}
