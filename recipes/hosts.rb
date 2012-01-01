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
  variables(
    :hosts => [ "33.33.33.21","33.33.33.20" ]
  )
end
