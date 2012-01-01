#
# Cookbook Name:: nagios-server
# Recipe:: nagios-server
#
# Copyright 2011, Brofist
#

deps = %w[httpd php gcc glibc glibc-common gd gd-devel curl]
dirs = %w[/opt/nagios /opt/nagios/etc /tmp/src]

deps.each do |m|
  package "#{m}" do
    action :install
  end
end

dirs.each do |m|
  directory "#{m}" do
    owner "root"
    owner "root"
    mode "0755"
    action :create
  end
end

user "nagios" do
  comment "Nagios User"
  home "/opt/nagios"
  shell "/bin/false"
  system true
end

group "nagcmd" do
  gid 602
  members ['nagios']
end

script "install_nag" do
  interpreter "bash"
  user "root"
  cwd "/tmp/src"
  code <<-EOH 
    wget http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-3.2.3.tar.gz
    wget http://prdownloads.sourceforge.net/sourceforge/nagiosplug/nagios-plugins-1.4.15.tar.gz
    tar xzf nagios-3.2.3.tar.gz
    cd nagios-3.2.3
    ./configure --prefix=/opt/nagios --with-cgiurl=/nagios/cgi-bin --with-htmurl=/nagios/ --with-nagios-user=nagios --with-nagios-group=nagios --with-command-group=nagcmd
    for i in all install install-init install-config install-commandmode install-webconf; do
      make $i
      sleep 2
    done
    htpasswd -cb /opt/nagios/etc/htpasswd.users nagiosadmin nagiosadmin
    service httpd restart
    cd /tmp/src
    tar xfz nagios-plugins-1.4.15.tar.gz
    cd nagios-plugins-1.4.15
    ./configure --with-nagios-user=nagios --with-nagios-group=nagios --prefix=/opt/nagios
    make
    make install
  EOH
end

template "/etc/httpd/conf.d/nagios.conf" do
  source "nagios_httpd.erb"
  mode 0644
  owner "apache"
  group "apache"
end

template "/opt/nagios/etc/nagios.cfg" do
  source "nagios_conf.erb"
  mode 0655
  owner "nagios"
  group "nagios"
end

template "/opt/nagios/etc/objects/hosts.cfg" do
  source "nagios_hosts.erb"
  mode 0655
  owner "nagios"
  group "nagios"
end
