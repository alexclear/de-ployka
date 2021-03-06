package Deployka;

use strict;
use warnings;
use Const::Fast;
use File::Copy;
use LWP::UserAgent;
use YAML ();
use File::Basename;

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
const our $option_path => 'path';
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
        my $loaded_config;
        eval { $loaded_config = YAML::LoadFile(${$options{$option_config}}) };
        die ${$options{$option_config}} . " is not in correct YAML format!\n" if $@;
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
    if((exists $options{$option_config}) && !(-f ${$options{$option_config}}) && !$replace_config) {
        die "No config file exists and no command line options are set!\n";
    }
    if((exists $options{$option_config}) && $replace_config) {
        _save_config(${$options{$option_config}}, %config);
    }
    if(!(exists $config{$option_application} && defined $config{$option_application})) {
        die "Please provide a path to an application file!\n";
    }
    ($config{$option_path} = basename($config{$option_application})) =~ s/\.[^.]+$//;
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
    my $response = $ua->put("http://" . $config{$option_hostname} . ":" . $config{$option_port} . "/manager/text/deploy?update=true&path=/" . $config{$option_path}, Content => $content);
    if ($response->is_success) {
        return 0;
    } else {
        die "Deploying failed: " . $response->status_line . "\n";
    }
}

sub undeploy {
    my %config = _parse_config( @_ );
    my $ua = _get_ua(%config);
    my $response = $ua->get("http://" . $config{$option_hostname} . ":" . $config{$option_port} . "/manager/text/undeploy?path=/" . $config{$option_path});
    if ($response->is_success) {
        return 0;
    } else {
        die "Undeploying failed: " . $response->status_line . "\n";
    }
}

sub stop {
    my %config = _parse_config( @_ );
    my $ua = _get_ua(%config);
    my $response = $ua->get("http://" . $config{$option_hostname} . ":" . $config{$option_port} . "/manager/text/stop?path=/" . $config{$option_path});
    if ($response->is_success) {
        return 0;
    } else {
        die "Stopping failed: " . $response->status_line . "\n";
    }
}

sub start {
    my %config = _parse_config( @_ );
    my $ua = _get_ua(%config);
    my $response = $ua->get("http://" . $config{$option_hostname} . ":" . $config{$option_port} . "/manager/text/start?path=/" . $config{$option_path});
    if ($response->is_success) {
        return 0;
    } else {
        die "Starting failed: " . $response->status_line . "\n";
    }
}

sub check {
    my %config = _parse_config( @_ );
    my $ua = _get_ua(%config);
    my $response = $ua->get("http://" . $config{$option_hostname} . ":" . $config{$option_port} . "/" . $config{$option_path} . "/");
    if ($response->is_success) {
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
