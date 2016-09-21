include_recipe 'hadoop::hdfs'

# Create the directory /var/hadoop/data
directory '/var/hadoop/data' do
	group node[:hadoop][:hadoop_group]
	mode '0770'
	recursive true
end

# Install the auto-start script
template '/etc/init.d/hadoop_datanode' do
	source 'hadoop_datanode.erb'
	mode '0755'
	variables({
		:hdfs_user => node[:hadoop][:hdfs_user],
		:hadoop_version => node[:hadoop][:version]
	})
end
execute 'ln -s ../init.d/hadoop_datanode /etc/rc3.d/S99hadoop_datanode' do
	not_if { ::File.exist?('/etc/rc3.d/S99hadoop_datanode') }
end

# Install the configuration file.
template '/etc/hadoop/core-site.xml' do
	source 'core-site.xml.erb'
	mode '0644'
	owner node[:hadoop][:hdfs_user]
	group node[:hadoop][:hadoop_group]
	variables({
		:namenode => node[:hadoop][:namenode]
	})
end
