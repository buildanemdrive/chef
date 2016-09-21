include_recipe 'hadoop::hdfs'

# Create the directory /var/hadoop/name
directory '/var/hadoop/name' do
	group node[:hadoop][:hadoop_group]
	mode '0770'
	recursive true
end

# Install the auto-start script
template '/etc/init.d/hadoop_namenode' do
	source 'hadoop_namenode.erb'
	mode '0755'
	variables({
		:hdfs_user => node[:hadoop][:hdfs_user],
		:hadoop_version => node[:hadoop][:version]
	})
end
execute 'ln -s ../init.d/hadoop_namenode /etc/rc3.d/S99hadoop_namenode' do
	not_if { ::File.exist?('/etc/rc3.d/S99hadoop_namenode') }
end

# Install the configuration file.
template '/etc/hadoop/hdfs-site.xml' do
	source 'hdfs-site.xml.erb'
	mode '0644'
	owner node[:hadoop][:hdfs_user]
	group node[:hadoop][:hadoop_group]
end

# Format the namenode
execute 'su - '+node[:hadoop][:hdfs_user]+' -c "/opt/hadoop-'+node[:hadoop][:version]+'/bin/hdfs namenode -format cluster"'
