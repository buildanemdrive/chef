include_recipe 'hadoop::yarn'

# Install the auto-start script
template '/etc/init.d/hadoop_resourcemanager' do
	source 'hadoop_resourcemanager.erb'
	mode '0755'
	variables({
		:yarn_user => node[:hadoop][:yarn_user],
		:hadoop_version => node[:hadoop][:version]
	})
end
execute 'ln -s ../init.d/hadoop_resourcemanager /etc/rc3.d/S99hadoop_resourcemanager' do
	not_if { ::File.exist?('/etc/rc3.d/S99hadoop_resourcemanager') }
end