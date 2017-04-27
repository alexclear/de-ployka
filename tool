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
const my $action_undeploy => "undeploy";

my $config = '/etc/deployka.yml';
my $hostname = 'localhost';
my $port = '8080';
my $user = '';
my $password = '';
my $action = $action_deploy;
my $application = 'hello-world.war';
my $timeout = $default_timeout;

my %options = ('config' => \$config,
               'hostname' => \$hostname,
               'port' => \$port,
               'user' => \$user,
               'password' => \$password,
               'action' => \$action,
               'application' => \$application,
               'timeout' => \$timeout
              );

sub validate_actions {
    my ($opt_name, $opt_value) = @_;
    if(!( grep { $_ eq $opt_value } ($action_deploy, $action_start, $action_undeploy) )) {
        die "valid actions are $action_deploy, $action_start or $action_undeploy";
    }
    $action = $opt_value;
}

GetOptions (\%options, "config=s", "hostname=s", "port=s", "password=s",
            "action=s", "application=s", "timeout=i")
or die "Error in command line arguments\n";

if(!( grep { $_ eq ${$options{'action'}} } ($action_deploy, $action_start, $action_undeploy) )) {
    die "valid actions are $action_deploy, $action_start or $action_undeploy";
}

if ($action eq $action_deploy) {
    print "deploy\n";
} elsif ($action eq $action_start) {
    print "start\n";
} elsif ($action eq $action_undeploy) {
    print "undeploy\n";
} else {
    die "This should not be possible!\n";
}
