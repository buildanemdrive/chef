include_recipe 'hadoop::hdfs'

# Create the directory /var/hadoop/data
directory '/var/hadoop/data' do
	owner node[:hadoop][:hdfs_user]
	group node[:hadoop][:hadoop_group]
	mode '0770'
	recursive true
end

systemd_unit 'hadoop_datanode.service' do
	enabled true
	active true
	content "[Unit]\nDescription=Hadoop Data Node\nBefore=runlevel3.target\nAfter=ssh.service\n\n[Install]\nAlias=hadoop_datanode\nWantedBy=runlevel3.target\n\n[Service]\nType=oneshot\nExecStart=/opt/hadoop-#{node[:hadoop][:version]}/sbin/hadoop-daemons.sh --config /etc/hadoop --script hdfs start datanode\nExecStop=/opt/hadoop-#{node[:hadoop][:version]}/sbin/hadoop-daemons.sh --config /etc/hadoop --script hdfs stop datanode\nUser=#{node[:hadoop][:hdfs_user]}\nRemainAfterExit=true\n"
	action :create
end