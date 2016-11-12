include_recipe 'hadoop::yarn'

systemd_unit 'hadoop_resourcemanager.service' do
	enabled true
	active true
	content "[Unit]\nDescription=Hadoop Resource Manager\nBefore=runlevel3.target\nAfter=ssh.service\n\n[Install]\nAlias=yarn_resourcemanager\nWantedBy=runlevel3.target\n\n[Service]\nType=oneshot\nExecStart=/opt/hadoop-#{node[:hadoop][:version]}/sbin/yarn-daemons.sh --config /etc/hadoop start resourcemanager\nExecStop=/opt/hadoop-#{node[:hadoop][:version]}/sbin/yarn-daemons.sh --config /etc/hadoop stop resourcemanager\nUser=#{node[:hadoop][:yarn_user]}\nRemainAfterExit=true\n"
	action :create
end