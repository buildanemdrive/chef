include_recipe 'hadoop::default'

user node[:hadoop][:kafka_user] do
	home "/home/#{node[:hadoop][:kafka_user]}"
	shell '/bin/bash'
	manage_home true
	group node[:hadoop][:hadoop_group]
end

remote_file "/opt/kafka_#{node[:hadoop][:kafka_version]}.tgz" do
	source "http://www.gtlib.gatech.edu/pub/apache/kafka/0.10.1.0/kafka_#{node[:hadoop][:kafka_version]}.tgz"
	group node[:hadoop][:hadoop_group]
	mode 770
	not_if { File.exist?("/opt/kafka_#{node[:hadoop][:kafka_version]}") }
end
execute "tar -xf /opt/kafka_#{node[:hadoop][:kafka_version]}.tgz -C /opt" do
	not_if { File.exist?("/opt/kafka_#{node[:hadoop][:kafka_version]}") }
end
execute "chown -R #{node[:hadoop][:kafka_user]}:#{node[:hadoop][:hadoop_group]} /opt/kafka_#{node[:hadoop][:kafka_version]}"

execute "mv /opt/kafka_#{node[:hadoop][:kafka_version]}/config /etc/kafka" do
	not_if { ::File.directory?('/etc/kafka') }
end
execute 'rm -Rf /opt/kafka_'+node[:hadoop][:kafka_version]+'/config' do
	only_if { ::File.exist?('/opt/kafka_'+node[:hadoop][:kafka_version]+'/config') }
	action :nothing
end
execute "ln -s /etc/kafka /opt/kafka_#{node[:hadoop][:kafka_version]}/config" do
	not_if { ::File.symlink?("/opt/kafka_#{node['hadoop']['kafka_version']}/config") }
end

directory node[:hadoop][:kafka_data_dir] do
	owner node[:hadoop][:kafka_user]
	group node[:hadoop][:hadoop_group]
	mode '0770'
	recursive true
end

template "/etc/kafka/server.properties" do
	source "server.properties.erb"
	owner node[:hadoop][:kafka_user]
	group node[:hadoop][:hadoop_group]
	mode '0644'
end

systemd_unit 'hadoop_kafka.service' do
	enabled true
	active true
	content "[Unit]\nDescription=Hadoop Kafka\nBefore=runlevel3.target\n\n[Install]\nAlias=hadoop_kafka\nWantedBy=runlevel3.target\n\n[Service]\nType=forking\nExecStart=/opt/kafka_#{node[:hadoop][:kafka_version]}/bin/kafka-server-start.sh -daemon /etc/kafka/server.properties\nExecStop=/opt/kafka_#{node[:hadoop][:kafka_version]}/bin/kafka-server-stop.sh\nUser=#{node[:hadoop][:kafka_user]}\nEnvironment=\"LOG_DIR=#{node[:hadoop][:kafka_log_dir]}\""
	action :create
end
