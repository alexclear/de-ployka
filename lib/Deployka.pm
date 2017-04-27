package Deployka;

use strict;
use warnings;
use Const::Fast;
use File::Copy;
use LWP::UserAgent;

our $VERSION = '0.01';

use Exporter;
our @ISA = 'Exporter';
our @EXPORT = qw(option_config);

const our $option_config => 'config';
const our $option_action => 'action';
const our $option_hostname => 'hostname';
const our $option_port => 'port';
const our $option_user => 'user';
const our $option_password => 'password';
const our $option_application => 'application';
const our $option_timeout => 'timeout';

sub deploy {
    my %options = @_;
    my %config;
    if((exists $options{$option_config}) && (-f ${$options{$option_config}})) {
        %config = parse_config(${$options{$option_config}});
    }
    if(exists $options{$option_hostname}) {
        $config{$option_hostname} = ${$options{$option_hostname}};
    }
    if(exists $options{$option_application}) {
        $config{$option_application} = ${$options{$option_application}};
    }
    if($config{$option_hostname} eq 'localhost') {
        copy($config{$option_application}, "/opt/tomcat8/webapps/") or die "Copy failed: $!";
    }
}

sub undeploy {
    my %options = @_;
    my %config;
    if((exists $options{$option_config}) && (-f ${$options{$option_config}})) {
        %config = parse_config(${$options{$option_config}});
    }
    if(exists $options{$option_hostname}) {
        $config{$option_hostname} = ${$options{$option_hostname}};
    }
    if(exists $options{$option_port}) {
        $config{$option_port} = ${$options{$option_port}};
    }
    if(exists $options{$option_application}) {
        $config{$option_application} = ${$options{$option_application}};
    }
    if(exists $options{$option_timeout}) {
        $config{$option_timeout} = ${$options{$option_timeout}};
    }
    if(exists $options{$option_user}) {
        $config{$option_user} = ${$options{$option_user}};
    }
    if(exists $options{$option_password}) {
        $config{$option_password} = ${$options{$option_password}};
    }
    my $ua = LWP::UserAgent->new;
    $ua->timeout($config{$option_timeout});
    $ua->credentials($config{$option_hostname} . ":" . $config{$option_port}, "Tomcat Manager Application", $config{$option_user}, $config{$option_password});
    my $response = $ua->get("http://" . $config{$option_hostname} . ":" . $config{$option_port} . "/manager/text/undeploy?path=/testwebapp-1");
    if ($response->is_success) {
        print("Undeployed!\n");
    } else {
        die "Undeploying failed: " . $response->status_line . "\n";
    }
}

1;
__END__

=head1 AUTHOR

Alex Chistyakov, E<lt>alexclear@gmail.comE<gt>

=cut
