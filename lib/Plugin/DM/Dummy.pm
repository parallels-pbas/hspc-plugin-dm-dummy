## Copyright (C) 1999-2012 Parallels IP Holdings GmbH and its affiliates.
## All rights reserved.
##
## Here should be placed presentation functions for Dummy plug-in
package HSPC::Plugin::DM::Dummy;

use strict;

## TODO: Review toolkit functions
use HSPC::PluginToolkit::General qw(string argparam log log_debug log_warn
	server_name);
use HSPC::PluginToolkit::HTMLTemplate qw{parse_template};
use HSPC::PluginToolkit::DM qw(callback_email callback_name);

use HSPC::MT::Plugin::DM::Dummy;

#### ------ config forms -------------------------------

use constant DM_DUMMY_ALWAYS_AVAILABLE => 1;
use constant DM_DUMMY_ALWAYS_OCCUPIED => 2;
use constant DM_DUMMY_USE_WHOIS => 3;

use constant MT_PLUGIN => 'HSPC::MT::Plugin::DM::Dummy';

sub view_config_form {
	my $class = shift; 
	my %arg = (
		config => undef,
		@_
	);
	## $conf is hashref:
	##  { lookup_mode => 1|2|3
	##    lookup_mode_tr => 1|2|3
	##    suppress_registration => 1|0
	##    suppress_transfer => 1|0
	##  }
	my $conf = $arg{config};
	
	my @conf_titles = (
		string('dm_dummy_mode'),
		string('dm_dummy_mode_tr'),
		string('dm_dummy_sup_reg'),
		string('dm_dummy_sup_tr'),
		string('dm_dummy_sup_ns_sync'),
##		'Callback Email Address'
	);
	
	## TODO: Remove hardcode 'Suppress Domain NS Synchronization'

	my %lookup_mode = (
		&DM_DUMMY_ALWAYS_AVAILABLE => string('dm_dummy_avail'),
		&DM_DUMMY_ALWAYS_OCCUPIED => string('dm_dummy_occ'),
		&DM_DUMMY_USE_WHOIS => string('dm_dummy_use_whois'),
	);
	
	my @conf_values;
	$conf_values[0] = $lookup_mode{$conf->{lookup_mode} || &DM_DUMMY_ALWAYS_AVAILABLE};
	$conf_values[1] = $lookup_mode{$conf->{lookup_mode_tr} || &DM_DUMMY_ALWAYS_AVAILABLE};
	$conf_values[2] = $conf->{suppress_registration} ? 1 : 0;
	$conf_values[3] = $conf->{suppress_transfer} ? 1 : 0;
	$conf_values[4] = $conf->{suppress_synchronize_domain_ns} ? 1 : 0;
##	$conf_values[5] = $conf->{callback_email} || callback_email();
	
	my $result = '';
	for (0..1) {
		$result .= parse_template(
			name => 'item_view_text.tmpl',
			data => {
				title => $conf_titles[$_],
				value => $conf_values[$_],
			}
		);
	}
	for (2..4) {
		$result .= parse_template(
			name => 'item_view_check.tmpl',
			data => {
				title => $conf_titles[$_],
				value => $conf_values[$_],
			}
		);
	}
##	for (5) {
##		$result .= parse_template(
##			name => 'item_view_text.tmpl',
##			data => {
##				title => $conf_titles[$_],
##				value => $conf_values[$_],
##			}
##		);
##	}

	return parse_template(
		name => 'table_view.tmpl',
		data => {
			value => $result,
		}
	);
}

sub edit_config_form  {
	my $class = shift; 
	my %arg = (
		config => undef,
		@_
	);
	my $conf = $arg{config};

	my @conf_titles = (
		string('dm_dummy_mode'),
		string('dm_dummy_mode_tr'),
		string('dm_dummy_sup_reg'),
		string('dm_dummy_sup_tr'),
		string('dm_dummy_sup_ns_sync'),
	);

	## TODO: Remove hardcode 'Suppress Domain NS Synchronization'

	$conf->{lookup_mode} ||= DM_DUMMY_ALWAYS_AVAILABLE;
	$conf->{lookup_mode_tr} ||= DM_DUMMY_ALWAYS_AVAILABLE;
	
	my $mode_options = [
		[&DM_DUMMY_ALWAYS_AVAILABLE , string('dm_dummy_avail')],
		[&DM_DUMMY_ALWAYS_OCCUPIED  , string('dm_dummy_occ')],
		[&DM_DUMMY_USE_WHOIS        , string('dm_dummy_use_whois')],
	];
	my $html = '';
	$html .= parse_template(
		name => 'item_edit_combo.tmpl',
		data => {
			title => string('dm_dummy_mode'),
			name => 'lookup_mode',
			value => $conf->{lookup_mode},
			options => $mode_options,
			no_default => 1,
		}
	);
	
	$html .= parse_template(
		name => 'item_edit_combo.tmpl',
		data => {
			title => string('dm_dummy_mode_tr'),
			name => 'lookup_mode_tr',
			value => $conf->{lookup_mode_tr},
			options => $mode_options,
			no_default => 1,
		}
	);
	
	$html .= parse_template(
		name => 'item_edit_check.tmpl',
		data => {
			title => string('dm_dummy_sup_reg'),
			name => 'suppress_registration',
			value => $conf->{suppress_registration},
		}
	);

	$html .= parse_template(
		name => 'item_edit_check.tmpl',
		data => {
			title => string('dm_dummy_sup_tr'),
			name => 'suppress_transfer',
			value => $conf->{suppress_transfer},
		}
	);

	$html .= parse_template(
		name => 'item_edit_check.tmpl',
		data => {
			title => string('dm_dummy_sup_ns_sync'),
			name => 'suppress_synchronize_domain_ns',
			value => $conf->{suppress_synchronize_domain_ns},
		}
	);

##	my $callback_email = $conf->{callback_email};
##	my ($callback_name,$server_name);
##	if($callback_email =~ /(.+)@(.+)/){
##		$callback_name = $1;
##		$server_name = $2;
##	}
##	$callback_name ||= callback_name();
##	$server_name ||= server_name();
##
##	$html .= parse_template(
##		name => 'item_edit_text.tmpl',
##		data => {
##			title => 'Callback Email Address',
##			name => 'callback_name',
##			value => $callback_name,
##			suffix => '@' . $server_name,
##			read_only => 0
##		}
##	);
##
##	$html .= qq|<input type = 'hidden' name = 'server_name' value = '$server_name'>|;

	## TODO: Remove hardcode 'Suppress Domain NS Synchronization'

	return parse_template(
		name => 'table_edit.tmpl',
		data => {
			value => $html,
		}
	);
}

sub collect_config_data {
	my $class = shift; 
##	my $callback_email = argparam('callback_name') . '@' . argparam('server_name');
	my $config_data = {
		lookup_mode => argparam('lookup_mode') || DM_DUMMY_ALWAYS_AVAILABLE,
		lookup_mode_tr => argparam('lookup_mode_tr') || DM_DUMMY_ALWAYS_AVAILABLE,
		suppress_registration => argparam('suppress_registration') ? '1' : '0',
		suppress_transfer => argparam('suppress_transfer') ? 1 : 0,
		suppress_synchronize_domain_ns => argparam('suppress_synchronize_domain_ns') ? 1 : 0,
##		callback_email => $callback_email
	};

	return {
		config => $config_data,
##		callback_email => $callback_email
	};
}

##
## Draw contact edit form
##
sub edit_contact_form {
	my $class = shift;
	my %arg = (
		domain			=> undef,
		action			=> undef,
		contact			=> undef,
		contact_type	=> undef,
		contact_extdata	=> undef,
		error_list		=> undef,
		@_
	);
	my $domain			= $arg{domain};
	my $action			= $arg{action};
	my $contact			= $arg{contact};
	my $contact_type	= $arg{contact_type};
	my $contact_extdata	= $arg{contact_extdata};
	my $error_list		= $arg{error_list};
	my $prefix;

	my $html;

	my $prefix = $class->_create_unique_name_prefix(
		tokens => ['item', $domain, $contact_type]
	);

	$html .= parse_template(
		name => 'base_edit_contact.tmpl',
		data => {
			form_prefix => $prefix,

			is_corporate	=> $contact->{is_corporate},
			org_name		=> $contact->{org_name},

			fname	=> $contact->{fname},
			lname	=> $contact->{lname},
			email	=> $contact->{email},
			address	=> $contact->{address},
			city	=> $contact->{city},
			state	=> $contact->{state},
			zip		=> $contact->{zip},
			country	=> $contact->{country},
			phone	=> $contact->{phone},
			fax		=> $contact->{fax},
			hide_fax=> 0
		}
	);

	return parse_template(
		name => 'table_edit.tmpl',
		data => {
			value => $html
		}
	);
}

##
## Draw contact view form
##
sub view_contact_form {
	my $class = shift;
	my %arg = (
		domain			=> undef,
		action			=> undef,
		contact			=> undef,
		contact_type	=> undef,
		contact_extdata	=> undef,
		@_
	);
	my $domain			= $arg{domain};
	my $action			= $arg{action};
	my $contact			= $arg{contact};
	my $contact_type	= $arg{contact_type};
	my $contact_extdata	= $arg{contact_extdata};
	my $prefix;

	my $html;

	$html .= parse_template(
		name => 'base_view_contact.tmpl',
		data => {
			is_corporate	=> $contact->{is_corporate},
			org_name		=> $contact->{org_name},

			fname	=> $contact->{fname},
			lname	=> $contact->{lname},
			email	=> $contact->{email},
			address	=> $contact->{address},
			city	=> $contact->{city},
			state	=> $contact->{state},
			zip		=> $contact->{zip},
			country	=> $contact->{country},
			phone	=> $contact->{phone},
			fax		=> $contact->{fax},
			hide_fax=> 0
		}
	);
	
	return parse_template(
		name => 'table_view.tmpl',
		data => {
			value => $html,
		}
	);
}

##
## Collect contact forms data
##
sub collect_contacts_data {
	my $class = shift;
	my %h = (
		domain => undef,
		action => undef,
		@_
	);

	## TODO: Create real collector!

	my $types = &MT_PLUGIN()->get_contact_types();

	my $type_id;
	my $contact;
	my $contacts = {};
	my $contacts_extdata = {};
	my $prefix;

	foreach my $ct (@$types) {
		$type_id = $ct->{type};
		$prefix = $class->_create_unique_name_prefix(
			tokens => ['item', $h{domain}, $type_id]
		);
		$contact = {
			fname		=> ''.argparam("$prefix\_fname"),
			lname		=> ''.argparam("$prefix\_lname"),
			address		=> ''.argparam("$prefix\_address"),
			city		=> ''.argparam("$prefix\_city"),
			state		=> ''.argparam("$prefix\_state"),
			zip			=> ''.argparam("$prefix\_zip"),
			country		=> ''.argparam("$prefix\_country"),
			email		=> ''.argparam("$prefix\_email"),
			phone		=> join ('|',
				(
					''.argparam("$prefix\_phone_country_code"),
					''.argparam("$prefix\_phone_area_code"),
					''.argparam("$prefix\_phone_number"),
					''.argparam("$prefix\_phone_extension"),
				)
			),
			fax			=> join ('|',
				(
					''.argparam("$prefix\_fax_country_code"),
					''.argparam("$prefix\_fax_area_code"),
					''.argparam("$prefix\_fax_number"),
					''.argparam("$prefix\_fax_extension"),
				)
			),
			is_corporate=> ''.argparam("$prefix\_is_corporate"),
			org_name	=> ''.argparam("$prefix\_org_name")
		};
		$contacts->{$type_id} = $contact;
		$contacts_extdata->{$type_id} = ['contact extended data'];
	}

	return {
		contacts => $contacts,
		contacts_extdata => $contacts_extdata
	};
}

##
## ----------------- Private methods ------------------------------------------
##

sub _create_unique_name_prefix {
	my $class = shift;
	my %h = (
		tokens => [],
		@_
	);
	return undef unless scalar @{$h{tokens}};
	my $unique = join('_', @{$h{tokens}});
	$unique =~ s#[^\w\d\_]#\_#g;
	return $unique;
}

sub get_help_page {
	my $class = shift;
	my %h = (
		action => undef,
		language => undef,
		config => undef,
		@_
	);
	my $action = $h{action};
	my $language = $h{language};

	my $help_page;
	if($action =~ /^(about|new|view|edit)$/){
		my $tmpl_name = "dummy_dm_$action.html";
		$help_page = parse_template(
			path => __PACKAGE__ . '::help::' . uc($language),
			name => $tmpl_name
		);
	}

	return $help_page;
}

1;
