docker run -it --net=host \
  -p 60000:60000 -p 60010:60010 -p 60020:60020 -p 60030:60030 \
  -p 2888:2888 -p 3888:3888 -p 2181:2181 \
  -p 21222:21222 \
  pls331/centos:hbase-1.2.6-standalone_hdfs /etc/bootstrap.sh -bash
