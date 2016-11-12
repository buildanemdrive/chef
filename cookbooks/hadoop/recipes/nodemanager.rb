include_recipe 'hadoop::yarn'

template '/etc/hadoop/yarn-site.xml' do
	source 'yarn-site.xml.erb'
	mode '0644'
	owner node[:hadoop][:yarn_user]
	group node[:hadoop][:hadoop_group]
	variables({
		:resourcemanager => node[:hadoop][:resourcemanager]
	})
end

systemd_unit 'hadoop_nodemanager.service' do
	enabled true
	active true
	content "[Unit]\nDescription=Hadoop Node Manager\nBefore=runlevel3.target\nAfter=ssh.service\n\n[Install]\nAlias=yarn_nodemanager\nWantedBy=runlevel3.target\n\n[Service]\nType=oneshot\nExecStart=/opt/hadoop-#{node[:hadoop][:version]}/sbin/yarn-daemons.sh --config /etc/hadoop start nodemanager\nExecStop=/opt/hadoop-#{node[:hadoop][:version]}/sbin/yarn-daemons.sh --config /etc/hadoop stop nodemanager\nUser=#{node[:hadoop][:yarn_user]}\nRemainAfterExit=true\n"
	action :create
end