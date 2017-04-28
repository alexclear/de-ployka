package Deployka;

use strict;
use warnings;
use Const::Fast;
use File::Copy;
use LWP::UserAgent;
use YAML ();

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

sub _save_config {
    my ($path, %config) = @_;
    YAML::DumpFile($path . ".tmp", \%config);
    # Let's do it atomically!
    move($path . ".tmp", $path);
}

sub _parse_config {
    my %options = @_;
    my %config;
    my $replace_config = 0;
    if((exists $options{$option_config}) && (-f ${$options{$option_config}})) {
        my $loaded_config = YAML::LoadFile(${$options{$option_config}});
        $config{$_} = $loaded_config->{$_} for keys %{$loaded_config};
    }
    if(exists $options{$option_hostname} && defined ${$options{$option_hostname}}) {
        $config{$option_hostname} = ${$options{$option_hostname}};
        $replace_config = 1;
    }
    if(exists $options{$option_port} && defined ${$options{$option_port}}) {
        $config{$option_port} = ${$options{$option_port}};
        $replace_config = 1;
    }
    if(exists $options{$option_application} && defined ${$options{$option_application}}) {
        $config{$option_application} = ${$options{$option_application}};
        $replace_config = 1;
    }
    if(exists $options{$option_timeout} && defined ${$options{$option_timeout}}) {
        $config{$option_timeout} = ${$options{$option_timeout}};
        $replace_config = 1;
    }
    if(exists $options{$option_user} && defined ${$options{$option_user}}) {
        $config{$option_user} = ${$options{$option_user}};
        $replace_config = 1;
    }
    if(exists $options{$option_password} && defined ${$options{$option_password}}) {
        $config{$option_password} = ${$options{$option_password}};
        $replace_config = 1;
    }
    if((exists $options{$option_config}) && $replace_config) {
        _save_config(${$options{$option_config}}, %config);
    }
    return %config;
}

sub _get_ua {
    my %config = @_;
    my $ua = LWP::UserAgent->new;
    $ua->timeout($config{$option_timeout});
    $ua->credentials($config{$option_hostname} . ":" . $config{$option_port}, "Tomcat Manager Application", $config{$option_user}, $config{$option_password});
    return $ua;
}

sub deploy {
    my %config = _parse_config( @_ );
    my $ua = _get_ua(%config);
    open my $fh, '<', $config{$option_application} || die $!;
    binmode $fh;
    my $content = do { local $/; <$fh> };
    close $fh;
    my $response = $ua->put("http://" . $config{$option_hostname} . ":" . $config{$option_port} . "/manager/text/deploy?update=true&path=/testwebapp-1", Content => $content);
    if ($response->is_success) {
        print("Deployed!\n");
        return 0;
    } else {
        die "Deploying failed: " . $response->status_line . "\n";
    }
}

sub undeploy {
    my %config = _parse_config( @_ );
    my $ua = _get_ua(%config);
    my $response = $ua->get("http://" . $config{$option_hostname} . ":" . $config{$option_port} . "/manager/text/undeploy?path=/testwebapp-1");
    if ($response->is_success) {
        print("Undeployed!\n");
        return 0;
    } else {
        die "Undeploying failed: " . $response->status_line . "\n";
    }
}

sub stop {
    my %config = _parse_config( @_ );
    my $ua = _get_ua(%config);
    my $response = $ua->get("http://" . $config{$option_hostname} . ":" . $config{$option_port} . "/manager/text/stop?path=/testwebapp-1");
    if ($response->is_success) {
        print("Stopped!\n");
        return 0;
    } else {
        die "Stopping failed: " . $response->status_line . "\n";
    }
}

sub start {
    my %config = _parse_config( @_ );
    my $ua = _get_ua(%config);
    my $response = $ua->get("http://" . $config{$option_hostname} . ":" . $config{$option_port} . "/manager/text/start?path=/testwebapp-1");
    if ($response->is_success) {
        print("Started!\n");
        return 0;
    } else {
        die "Starting failed: " . $response->status_line . "\n";
    }
}

sub check {
    my %config = _parse_config( @_ );
    my $ua = _get_ua(%config);
    my $response = $ua->get("http://" . $config{$option_hostname} . ":" . $config{$option_port} . "/testwebapp-1/");
    if ($response->is_success) {
        print("Checked!\n");
        return 0;
    } else {
        return 1;
    }
}

1;
__END__

=head1 AUTHOR

Alex Chistyakov, E<lt>alexclear@gmail.comE<gt>

=cut
