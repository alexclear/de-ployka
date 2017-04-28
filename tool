#!/usr/bin/env perl

use strict;
no strict 'refs';
use warnings FATAL => 'all';

use Const::Fast;
use Getopt::Long;
use List::Util qw(any);
use Deployka;

const my $action_deploy => "deploy";
const my $action_start => "start";
const my $action_stop => "stop";
const my $action_undeploy => "undeploy";
const my $action_check => "check";

my $config = '/etc/deployka.yml';
my $hostname = undef;
my $port = undef;
my $user = undef;
my $password = undef;
my $action = $action_deploy;
my $application = undef;
my $timeout = undef;

my %options = ($Deployka::option_config => \$config,
               $Deployka::option_hostname => \$hostname,
               $Deployka::option_port => \$port,
               $Deployka::option_user => \$user,
               $Deployka::option_password => \$password,
               $Deployka::option_action => \$action,
               $Deployka::option_application => \$application,
               $Deployka::option_timeout => \$timeout
              );

GetOptions (\%options, "config=s", "hostname=s", "port=s", "password=s",
            "action=s", "application=s", "timeout=i", "user=s")
or die "Error in command line arguments\n";

if(!( grep { $_ eq ${$options{$Deployka::option_action}} } ($action_deploy, $action_stop, $action_start, $action_check, $action_undeploy) )) {
    die "valid actions are $action_deploy, $action_start, $action_stop, $action_check or $action_undeploy";
}

my $sub_name = "Deployka::" . $action;
exit ($sub_name->(%options));
