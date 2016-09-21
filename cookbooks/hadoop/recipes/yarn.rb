include_recipe 'default'

user node['hadoop']['yarn_user'] do
	home '/home/' + node['hadoop']['yarn_user']
	shell '/bin/bash'
end
execute 'echo "export HADOOP_PREFIX=/opt/hadoop-'+node[:hadoop][:version]+'" >> /home/'+node[:hadoop][:hdfs_user]+'/.profile'
execute 'echo "export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64" >> /home/'+node[:hadoop][:hdfs_user]+'/.profile'