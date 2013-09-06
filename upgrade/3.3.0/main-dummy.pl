#!/usr/bin/perl
use strict;

use HSPC::WebDB qw(is_table_exists select_hashrows select_result select_run);
use Storable qw(freeze);

my $old_plugin_id = 'Dummy';
my $plugin_table = 'dm_plugin_config_dummy';
my $common_fields = {};
my $plugin_fields = {
	'lookup_mode' => ['lookup_mode',1],
	'lookup_mode_tr' => ['lookup_mode_tr',1],
	'suppress_registration' => ['suppress_registration',0],
	'suppress_transfer' => ['suppress_transfer',0]
};
my $new_fields = {
	'suppress_synchronize_domain_ns' => 0
};

sub custom_operations {
	my $config_data = shift;
	return undef;
}

sub is_valid_tables {
	my $structure = shift;

	my $is_valid = 1;
	foreach my $table (keys(%$structure)){
		if(!is_table_exists(table => $table)){
			print "Table '$table' not exists!\n";
			$is_valid = 0;
			last;
		}

		my $description = select_hashrows('desc ' . lc($table));
		foreach my $existent_column (@$description){
			$existent_column->{lc_Field} = lc($existent_column->{Field});
		}

		my $columns = $structure->{$table};
		foreach my $column (@$columns){
			my $lc_column = lc($column);
			my $is_found = 0;
			foreach my $existent_column (@$description){
				if($existent_column->{lc_Field} eq $lc_column){
					$is_found = 1;
					last;
				}
			}
			if(!$is_found){
				print "Column '$lc_column' not exists in table '$table'!\n";
				$is_valid = 0;
				last;
			}
		}
	}
	return $is_valid;
}

my $base_common_fields = ['plugin_id','vendor_id'];
my $base_plugin_fields = ['plugin_id','vendor_id'];

my $vendor_id = 1;

push(@$base_common_fields,keys(%$common_fields));
push(@$base_plugin_fields,keys(%$plugin_fields));

my $common_field_list = join(', ',@$base_common_fields);
my $plugin_field_list = join(', ',@$base_plugin_fields);

my $config_data = {};
my $cross_keys = {};
foreach my $fields ($common_fields,$plugin_fields){
	while(my ($key,$value) = each %$fields){
		$cross_keys->{$key} = $value->[0];
		$config_data->{$value->[0]} = $value->[1];
	}
}

foreach my $new_field (keys(%{$new_fields})){
	$config_data->{$new_field} = $new_fields->{$new_field};
}

my $old_config_structure = {'dm_plugin_config_common' => $base_common_fields};
$old_config_structure->{$plugin_table} = $base_plugin_fields
	if($plugin_table);

my $is_valid = is_valid_tables($old_config_structure);
if($is_valid){
	my $old_common_configs = select_hashrows(
		"SELECT $common_field_list " .
		"FROM dm_plugin_config_common " .
		"WHERE plugin_id = '$old_plugin_id' " .
		"AND vendor_id = $vendor_id;"
	);

	foreach my $old_common_config (@$old_common_configs){
		foreach my $old_common_key (keys(%$common_fields)){
			$config_data->{$cross_keys->{$old_common_key}} = $old_common_config->{$old_common_key};
		}

		if($plugin_table){
			my $old_plugin_configs = select_hashrows(
				"SELECT $plugin_field_list " .
				"FROM $plugin_table " .
				"WHERE plugin_id = '$old_plugin_id' " .
				"AND vendor_id = $vendor_id;"
			);

			foreach my $old_plugin_config (@$old_plugin_configs){
				foreach my $old_config_key (keys(%$plugin_fields)){
					$config_data->{$cross_keys->{$old_config_key}} = $old_plugin_config->{$old_config_key};
				}
			}
		}
	}

	custom_operations($config_data);

	my $freezed_config_data = freeze($config_data);

	my $new_common_configs = select_hashrows(
		"SELECT id " .
		"FROM plugin " .
		"WHERE template_id = '$old_plugin_id' " .
		"AND vendor_id = $vendor_id;"
	);

	my $new_plugin_id;
	foreach my $new_common_config (@$new_common_configs){
		$new_plugin_id = $new_common_config->{id};
	}
	if(defined($new_plugin_id)){
		select_run(
			"UPDATE plugin " .
			"SET config_data = ? " .
			"WHERE id = $new_plugin_id",
			$freezed_config_data
		);
	}
}
