#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use Const::Fast;
use Getopt::Long;
use List::Util qw(any);
use Deployka;

const my $default_timeout => 10;
const my $action_deploy => "deploy";
const my $action_start => "start";
const my $action_stop => "stop";
const my $action_undeploy => "undeploy";
const my $action_check => "check";

my $config = '/etc/deployka.yml';
my $hostname = 'localhost';
my $port = '8080';
my $user = '';
my $password = '';
my $action = $action_deploy;
my $application = 'hello-world.war';
my $timeout = $default_timeout;

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

if ($action eq $action_deploy) {
    print "deploying\n";
    exit Deployka::deploy(%options);
} elsif ($action eq $action_stop) {
    print "stopping\n";
    exit Deployka::stop(%options);
} elsif ($action eq $action_start) {
    print "starting\n";
    exit Deployka::start(%options);
} elsif ($action eq $action_check) {
    print "checking\n";
    exit Deployka::check(%options);
} elsif ($action eq $action_undeploy) {
    print "undeploying\n";
    exit Deployka::undeploy(%options);
} else {
    die "This should not be possible!\n";
}
