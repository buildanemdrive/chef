include_recipe 'hadoop::yarn'

# Install the auto-start script
template '/etc/init.d/hadoop_nodemanager' do
	source 'hadoop_nodemanager.erb'
	mode '0755'
	variables({
		:yarn_user => node[:hadoop][:yarn_user],
		:hadoop_version => node[:hadoop][:version]
	})
end
execute 'ln -s ../init.d/hadoop_nodemanager /etc/rc3.d/S99hadoop_nodemanager' do
	not_if { ::File.exist?('/etc/rc3.d/S99hadoop_nodemanager') }
end