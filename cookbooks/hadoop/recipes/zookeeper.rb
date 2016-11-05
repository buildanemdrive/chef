include_recipe 'hadoop::default'

user node['hadoop']['zookeeper_user'] do
	home '/home/' + node['hadoop']['zookeeper_user']
	shell '/bin/bash'
	manage_home true
	group node[:hadoop][:hadoop_group]
end

remote_file "/opt/zookeeper-#{node[:hadoop][:zookeeper_version]}" do
	source 'http://shinyfeather.com/zookeeper/zookeeper-3.4.9/zookeeper-3.4.9.tar.gz'
	mode '0755'
	action :create_if_missing
end

execute "tar -xf /opt/zookeeper-#{node[:hadoop][:zookeeper_version]}" do
	not_if { File.exist?("/opt/zookeeper-#{node[:hadoop][:zookeeper_version]}") }
end
execute "chown -R #{node[:hadoop][:zookeeper_user]}:#{node[:hadoop][:hadoop_group]} /opt/zookeeper-#{node[:hadoop][:zookeeper_version]}"

template "/opt/zookeeper-#{node[:hadoop][:zookeeper_version]}/conf/zookeeper.properties" do
	group node[:hadoop][:hadoop_group]
	mode '0770'
end