#
# Cookbook Name:: hadoop
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

execute 'apt-get update'

package 'openjdk-7-jdk' do
	version '7u51-2.4.6-1ubuntu4'
	action :install
end

group node[:hadoop][:hadoop_group] do
	action [:create, :modify]
	append true
	members node['hadoop']['hdfs-user']
end

# Establish the installation directory
cookbook_file 'hadoop-'+node[:hadoop][:version]+'.tar.gz' do
	source 'hadoop-'+node[:hadoop][:version]+'.tar.gz'
	path '/opt/hadoop-'+node[:hadoop][:version]+'.tar.gz'
	group node[:hadoop][:hadoop_group]
	mode 770
end
execute 'tar -xf /opt/hadoop-'+node[:hadoop][:version]+'.tar.gz -C /opt'
execute 'chown -R root:'+node[:hadoop][:hadoop_group]+' /opt/hadoop-'+node[:hadoop][:version]

# Etc
execute 'mv /opt/hadoop-'+node[:hadoop][:version]+'/etc/hadoop /etc' do
	not_if { ::File.directory?('/etc/hadoop') }
end
execute 'rm -Rf /opt/hadoop-'+node[:hadoop][:version]+'/etc/hadoop' do
	only_if { ::File.exist?('/opt/hadoop-'+node[:hadoop][:version]+'/etc/hadoop') }
end
execute 'ln -s /etc/hadoop /opt/hadoop-'+node[:hadoop][:version]+'/etc/hadoop' do
	not_if { ::File.exist?('/opt/hadoop'+node['hadoop']['version']+'/etc/hadoop') }
end

# Logs
directory '/var/log/hadoop' do
	owner 'root'
	group node[:hadoop][:hadoop_group]
	mode '0770'
end
execute 'ln -s /var/log/hadoop /opt/hadoop-'+node[:hadoop][:version]+'/logs' do
	not_if { ::File.exist?('/opt/hadoop-'+node['hadoop']['version']+'/logs') }
end