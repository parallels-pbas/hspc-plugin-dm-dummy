## Copyright (C) 1999-2012 Parallels IP Holdings GmbH and its affiliates.
## All rights reserved.
##
## Here should be placed MT template functions for Dummy plug-in
package HSPC::MT::Plugin::DM::Dummy;

use strict;

use HSPC::PluginToolkit::General qw (string log log_debug log_warn);
use HSPC::PluginToolkit::DM;
use HSPC::MT::Plugin::DM::Dummy::Constants;
use Mail::Internet;

sub get_contact_types {
	my $class = shift;
	return [
		{type => 'owner',		title => string('dm_dummy_contact_owner')},
		{type => 'admin',		title => string('dm_dummy_contact_admin')},
		{type => 'billing',		title => string('dm_dummy_contact_bill')},
		{type => 'technical',	title => string('dm_dummy_contact_tech')},
	];
}

sub validate_data {
	my $class = shift;
	my %h = (
		domain => undef,
		action => undef,
		contacts => undef,
		domain_extdata => undef,
		@_
	);

	## Here should be placed a code for validating data before
	## registration/transferring
	##
	## Note: For Dummy plug-in this is not needed

	return {
		is_valid => 1,
	};
}

sub check_register {
	my $class = shift;
	my %h = (
		domains => [],
		config => undef,
		@_
	);

	my $config = $h{config};

	my $status;
	if($config->{lookup_mode} == &DM_DUMMY_ALWAYS_AVAILABLE){
		$status = 1;
	}
	elsif($config->{lookup_mode} == &DM_DUMMY_ALWAYS_OCCUPIED){
		$status = 0;
	}
	elsif($config->{lookup_mode} == &DM_DUMMY_USE_WHOIS){
		$status = 3;
	}

	my %res = map {$_ => $status} @{$h{domains}};
	return \%res;
}

sub check_transfer {
	my $class = shift;
	my %h = (
		domains => [],
		config => undef,
		@_
	);

	my $config = $h{config};

	my $status;
	if($config->{lookup_mode_tr} == &DM_DUMMY_ALWAYS_AVAILABLE){
		$status = 1;
	}
	elsif($config->{lookup_mode_tr} == &DM_DUMMY_ALWAYS_OCCUPIED){
		$status = 0;
	}
	elsif($config->{lookup_mode_tr} == &DM_DUMMY_USE_WHOIS){
		$status = 3;
	}

	my %res = map {$_ => $status} @{$h{domains}};
	return \%res;
}

sub synchronize_domain_ns {
	my $self = shift;
	my %h = (
		domain => undef,
		nses => [],
		config => undef,
		@_
	);
	my $config = $h{config};

	log_debug('Dummy->synchronize_domain_ns() suppress=' . $config->{suppress_synchronize_domain_ns});
	my $result;
	if(!$config->{suppress_synchronize_domain_ns}){
		$result = {
			is_success => 1,
			ns_statuses => {map {$_->{hostname} => 'synchronized'} @{$h{nses}}},
			message => 'Name Server Synchronization was successfully completed.'
		};
	} else {
		$result = {
			is_success => 0,
			message => string('dm_dummy_err_suppressed_ns_sync'),
		};
	}

	## TODO: Remove hardcode.

	return $result;
}

sub register_domain {
	my $class = shift;
	my %h = (
		domain => undef,
		period => undef,
		nses => [],
		contacts => undef,
		domain_extdata => undef,
		
		config => undef,
		@_
	);
	
	my $config = $h{config};
	
	if ($config->{suppress_registration}) {
		return {
			is_success => 0,
			message => string('dm_dummy_err_suppressed_reg'),
			domain_status => 'error',
		};
	}

	log_debug('Dummy->register_domain() complete for domain: ' . $h{domain} .
		', period: ' . $h{period} . '.');
	
	return {
		is_success => 1,
		domain_status => 'registered'
	};
}

sub transfer_domain {
	my $class = shift;
	my %h = (
		domain => undef,
		period => undef,
		nses => [],
		contacts => undef,
		domain_extdata => undef,
		
		config => undef,
		@_
	);
	
	my $config = $h{config};
	
	if ($config->{suppress_transfer}) {
		return {
			is_success => 0,
			message => string('dm_dummy_err_suppressed_tr'),
			domain_status => 'error',
		};
	}
	
	return {
		is_success => 1,
		domain_status => 'transferred'
	};
}

sub can_transfer_domain {
	my $class = shift;
	return 1;
}

sub renew_domain {
	my $class = shift;
	my %h = (
		domain => undef,
		period => undef,
		config => undef,
		@_
	);
	log_debug('Dummy->renew_domain() complete for domain: ' . $h{domain} .
		', period: ' . $h{period} . '.');
	return {
		is_success => 1,
		domain_status => 'renewed'
	};
}

sub update_contacts {
	my $class = shift;
	my %h = (
		domain => undef,
		contacts => undef,
		contacts_extdata => undef,
		contacts_ids => undef,
		@_
	);

	## Here should be placed a code for updating contacts data
	## on registrar side
	##
	## Note: For Dummy plug-in this is not needed

	return { is_success => 1 };
}

sub can_reglock{
	return 1;
}

sub get_reglock {
	my $class = shift;
	my %h = (
		domain => undef,
		@_
	);
	return {
		is_success => 1,
		value => 0
	};
}

sub set_reglock{
	return {
		is_success => 0,
		message => string('dm_dummy_no_reglock') ## Dummy doesn't support registrar lock change
	};
}

##sub process_callback {
##	my $class = shift;
##	my %h = (
##		data => undef,
##		@_
##	);
##	my $data = $h{data};
##	my @lines = split (/\n/, $data);
##	my $mail = Mail::Internet->new(\@lines);
##	my $header = $mail->head();
##	my $subj = $header->get('Subject');
##	my $from = $header->get('From');
##	my $body = $mail->body();
##
##	log_debug("Dummy->process_callback() register incoming email " .
##		" from '$from' with subject '$subj'.");
##
##	my $result = {is_success => 1};
##
##	my $step = 0;
##	foreach my $body_line (@$body){
##		$body_line = uc($body_line);
##		if(($step == 0) && ($body_line =~ m/^DOMAIN=(.+\..+)$/)){
##			$result->{domain} = $1;
##			$step = 1;
##		}
##		elsif(($step == 1) && ($body_line =~ m/^STATUS=(.+)$/)){
##			$result->{domain_status} = lc($1);
##			$step = 2;
##		}
##		elsif($step > 1){
##			last;
##		}
##	}
##
##	if(($step < 2) || !($result->{domain}) || !($result->{domain_status})){
##		$result->{is_success} = 0;
##		$result->{message} = "Parser error. Response is corrupted.";
##	}
##
##	return $result;
##}

##sub get_domain_prices {
##	my $class = shift;
##	my %h = (
##		periods => undef,
##		config => undef,
##		@_
##	);
##	my $periods = $h{periods};
##	my $price = 10;
##
##	my $result_prices = {};
##	foreach my $domain (keys(%$periods)){
##		my $domain_periods = $periods->{$domain};
##		my $domain_prices = {};
##		foreach my $period (@$domain_periods){
##			$domain_prices->{$period} = $period*$price;
##		}
##		$result_prices->{$domain} = $domain_prices;
##	}
##
##	return {
##		is_success => 1,
##		prices => $result_prices
##	};
##}

##sub get_domain_status {
##	my $class = shift;
##	my %h = (
##		domain => undef,
##		config => undef,
##		@_
##	);
##	return {
##		is_success => 1,
##		domain_status => 'registered'
##	}
##}

1;
