include_recipe 'hadoop::default'

user node['hadoop']['hdfs_user'] do
	home '/home/' + node['hadoop']['hdfs_user']
	shell '/bin/bash'
	manage_home true
	group node[:hadoop][:hadoop_group]
end

execute 'echo "export HADOOP_PREFIX=/opt/hadoop-'+node[:hadoop][:version]+'" >> /home/'+node[:hadoop][:hdfs_user]+'/.profile'
execute 'echo "export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64" >> /home/'+node[:hadoop][:hdfs_user]+'/.profile'