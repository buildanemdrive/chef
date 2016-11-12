include_recipe 'hadoop::default'

user node['hadoop']['zookeeper_user'] do
	home '/home/' + node['hadoop']['zookeeper_user']
	shell '/bin/bash'
	manage_home true
	group node[:hadoop][:hadoop_group]
end

remote_file "/opt/zookeeper-#{node[:hadoop][:zookeeper_version]}.tar.gz" do
	source 'http://shinyfeather.com/zookeeper/zookeeper-3.4.9/zookeeper-3.4.9.tar.gz'
	mode '0755'
	action :create_if_missing
end

execute "tar -xf /opt/zookeeper-#{node[:hadoop][:zookeeper_version]}.tar.gz -C /opt" do
	not_if { File.exist?("/opt/zookeeper-#{node[:hadoop][:zookeeper_version]}") }
end
execute "chown -R #{node[:hadoop][:zookeeper_user]}:#{node[:hadoop][:hadoop_group]} /opt/zookeeper-#{node[:hadoop][:zookeeper_version]}"

directory '/var/hadoop/zookeeper' do
	mode '0755'
	owner node[:hadoop][:zookeeper_user]
	group node[:hadoop][:hadoop_group]
end

execute "mv /opt/zookeeper-#{node[:hadoop][:zookeeper_version]}/conf /etc/zookeeper" do
	not_if { ::File.directory?('/etc/zookeeper') }
end
execute "ln -s /etc/zookeeper /opt/zookeeper-#{node[:hadoop][:zookeeper_version]}/conf" do
	not_if { ::File.symlink?("/opt/zookeeper-#{node['hadoop']['zookeeper_version']}/conf") }
end

template "/opt/zookeeper-#{node[:hadoop][:zookeeper_version]}/conf/zoo.cfg" do
	group node[:hadoop][:hadoop_group]
	mode '0770'
end

template "/opt/zookeeper-#{node[:hadoop][:zookeeper_version]}/conf/log4j.properties" do
	source "zookeeper-log4j.properties.erb"
	owner node[:hadoop][:zookeeper_user]
	group node[:hadoop][:hadoop_group]
	mode '0664'
end

systemd_unit 'hadoop_zookeeper.service' do
	enabled true
	active true
	content "[Unit]\nDescription=Hadoop Zoo Keeper\nBefore=runlevel3.target\nAfter=ssh.service\n\n[Install]\nAlias=hadoop_zookeeper\nWantedBy=runlevel3.target\n\n[Service]\nType=forking\nExecStart=/opt/zookeeper-#{node[:hadoop][:zookeeper_version]}/bin/zkServer.sh start\nExecStop=/opt/zookeeper-#{node[:hadoop][:zookeeper_version]}/bin/zkServer.sh stop\nUser=#{node[:hadoop][:zookeeper_user]}\nRemainAfterExit=true\nEnvironment=\"ZOO_LOG_DIR=#{node[:hadoop][:log_dir]}\"\n"
	action :create
end
