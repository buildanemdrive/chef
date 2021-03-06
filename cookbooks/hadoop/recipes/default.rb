#
# Cookbook Name:: hadoop
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'hostname::default'

apt_update 'Update the apt cache daily' do
	frequency 86_400
	action :periodic
end

# Apparently this was not needed in Ubuntu because I had a private-public key pair for those servers. Consider revising this?
package 'ssh-askpass' do
	action :install
end

package 'openjdk-7-jdk' do
	case node[:platform]
	when 'ubuntu'
		version '7u51-2.4.6-1ubuntu4'
	when 'raspbian'
		version '7u101-2.6.6-2~deb8u1+rpi1'
	end
	action :install
end

group node[:hadoop][:hadoop_group] do
	action [:create, :modify]
	append true
	members node['hadoop']['hdfs-user']
end

# Establish the installation directory
remote_file "/opt/hadoop-#{node[:hadoop][:version]}.tar.gz" do
	source "http://apache.mirrors.lucidnetworks.net/hadoop/common/hadoop-#{node[:hadoop][:version]}/hadoop-#{node[:hadoop][:version]}.tar.gz"
	group node[:hadoop][:hadoop_group]
	mode 770
	not_if { File.exist?("/opt/hadoop-#{node[:hadoop][:version]}") }
end
execute 'tar -xf /opt/hadoop-'+node[:hadoop][:version]+'.tar.gz -C /opt' do
	not_if { File.exist?("/opt/hadoop-" + node[:hadoop][:version]) }
end
execute 'chown -R root:'+node[:hadoop][:hadoop_group]+' /opt/hadoop-'+node[:hadoop][:version]

# Etc
execute 'mv /opt/hadoop-'+node[:hadoop][:version]+'/etc/hadoop /etc' do
	not_if { ::File.directory?('/etc/hadoop') }
end
execute 'rm -Rf /opt/hadoop-'+node[:hadoop][:version]+'/etc/hadoop' do
	only_if { ::File.exist?('/opt/hadoop-'+node[:hadoop][:version]+'/etc/hadoop') }
	action :nothing
end
execute 'ln -s /etc/hadoop /opt/hadoop-'+node[:hadoop][:version]+'/etc/hadoop' do
	not_if { ::File.symlink?("/opt/hadoop-#{node['hadoop']['version']}/etc/hadoop") }
end

java_home=''
case node[:platform]
when 'ubuntu'
	java_home = '/usr/lib/jvm/java-7-openjdk-amd64'
when 'raspbian'
	java_home = '/usr/lib/jvm/java-7-openjdk-armhf'
end
template '/etc/hadoop/hadoop-env.sh' do
	group node[:hadoop][:hadoop_group]
	mode '0770'
	variables({
		:java_home => java_home
	})
end

# Logs
directory node[:hadoop][:log_dir] do
	owner 'root'
	group node[:hadoop][:hadoop_group]
	mode '0770'
end
execute 'ln -s /var/log/hadoop /opt/hadoop-'+node[:hadoop][:version]+'/logs' do
	not_if { ::File.exist?('/opt/hadoop-'+node['hadoop']['version']+'/logs') }
end
