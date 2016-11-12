include_recipe 'hadoop::default'

user node['hadoop']['yarn_user'] do
	home '/home/' + node['hadoop']['yarn_user']
	shell '/bin/bash'
	manage_home true
	group node[:hadoop][:hadoop_group]
end

execute "echo \"export HADOOP_PREFIX=/opt/hadoop-#{node[:hadoop][:version]}\" >> /home/#{node[:hadoop][:yarn_user]}/.profile" do
	not_if { File.readlines("/home/#{node[:hadoop][:yarn_user]}/.profile").grep(/HADOOP_PREFIX/).size > 0 }
end

java_home=''
case node[:platform]
when 'ubuntu'
	java_home = '/usr/lib/jvm/java-7-openjdk-amd64'
when 'raspbian'
	java_home = '/usr/lib/jvm/java-7-openjdk-armhf'
end
 
execute "echo \"export JAVA_HOME=#{java_home}\" >> /home/#{node[:hadoop][:yarn_user]}/.profile" do
	not_if { File.readlines("/home/#{node[:hadoop][:yarn_user]}/.profile").grep(/JAVA_HOME/).size > 0 }
end

directory "/home/#{node[:hadoop][:yarn_user]}/.ssh"
ssh_keygen "/home/#{node[:hadoop][:yarn_user]}/.ssh/id_rsa" do
	action :create
	owner node[:hadoop][:yarn_user]
	group node[:hadoop][:hadoop_group]
	strength 2048
	secure_directory true
end

remote_file "/home/#{node[:hadoop][:yarn_user]}/.ssh/authorized_keys" do
	owner node[:hadoop][:yarn_user]
	group node[:hadoop][:hadoop_group]
	mode '0755'
	source "file:///home/#{node[:hadoop][:yarn_user]}/.ssh/id_rsa.pub"
	action :create_if_missing
end