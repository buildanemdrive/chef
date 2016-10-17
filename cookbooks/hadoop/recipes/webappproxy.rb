include_recipe 'hadoop::yarn'

# Autostart script
#	[yarn]$ $HADOOP_YARN_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR start proxyserver
