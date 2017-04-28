# Deployka

Deployka is a Perl module which deploys and undeploys a WAR file to/from Tomcat using its management interface

## How to use

There is a command line tool called `tool` which uses the Deployka module.    
A default config file is at `/etc/deployka.yml` and should be in YAML format. You can override a config file location using `--config` command line option.    
It does not exist by default and will be created on first run if you provide all necessary command line options.    
Valid command line options are:    
- `--config PATH` path to a config file
- `--timeout NUMSEC` number of seconds to wait when performing a request to the Tomcat instance
- `--hostname HOSTNAME` a Tomcat host
- `--port PORT` a Tomcat port
- `--application WARFILE` path to an application WAR file
- `--user USERNAME` a username of a Tomcat management interface user
- `--password PASSWORD` a password of that user

## How to test

You should set up Vagrant and Ansible on a local machine.     
Vagrant uses Ansible as a provider.     
Test cases are present in a "deployka" Ansible role and run automatically when Vagrant provisions a host.    
Perform `vagrant up` to create and start provisioning a box.