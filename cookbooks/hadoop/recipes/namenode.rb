include_recipe 'hadoop::hdfs'

# Create the directory /var/hadoop/name
directory '/var/hadoop/name' do
	owner node[:hadoop][:hdfs_user]
	group node[:hadoop][:hadoop_group]
	mode '0770'
	recursive true
end

# Install the configuration file.
template '/etc/hadoop/hdfs-site.xml' do
	source 'hdfs-site.xml.erb'
	mode '0644'
	owner node[:hadoop][:hdfs_user]
	group node[:hadoop][:hadoop_group]
end

# Format the namenode
# This is put in as :nothing out because 1. we don't want it running every time, and 2. on reformat it prompts for a response and hangs the run.
execute "su - #{node[:hadoop][:hdfs_user]} -c \"/opt/hadoop-#{node[:hadoop][:version]}/bin/hdfs namenode -format cluster\"" do
	action :nothing
end

systemd_unit 'hadoop_namenode.service' do
	enabled true
	active true
	content "[Unit]\nDescription=Hadoop Name Node\nBefore=runlevel3.target\nAfter=ssh.service\n\n[Install]\nAlias=hadoop_namenode\nWantedBy=runlevel3.target\n\n[Service]\nType=oneshot\nExecStart=/opt/hadoop-#{node[:hadoop][:version]}/sbin/hadoop-daemons.sh --config /etc/hadoop --script hdfs start namenode\nExecStop=/opt/hadoop-#{node[:hadoop][:version]}/sbin/hadoop-daemons.sh --config /etc/hadoop --script hdfs stop namenode\nUser=#{node[:hadoop][:hdfs_user]}\nRemainAfterExit=true\n"
	action :create
end