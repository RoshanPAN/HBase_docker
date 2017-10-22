

# Creates pseudo distributed hadoop 2.7.4
#
# docker build -t sequenceiq/hadoop .
###
FROM sequenceiq/pam:centos-6.5
MAINTAINER LuoshangPan

USER root
###
# install dev tools
RUN yum clean all; \
    rpm --rebuilddb; \
    yum install -y curl which tar sudo openssh-server openssh-clients rsync nc wget git
# update libselinux. see https://github.com/sequenceiq/hadoop-docker/issues/14
RUN yum update -y libselinux


###
# passwordless ssh
# The authorized_keys file in SSH specifies the SSH keys that can be used
# for logging into the user account for which the file is configured.
# Allow itself to connect to itself (still need to add pub key of other server)
# All container will have the same private and public key, so they could connect
# to each other in this way 
# Use the host machine's ssh for container (so that all of them can communicate)
ADD id_rsa   /root/.ssh/id_rsa
ADD id_rsa.pub   /root/.ssh/id_rsa.pub
ADD authorized_keys  /root/.ssh/authorized_keys
ADD known_hosts   /root/.ssh/known_hosts


###
# java 1.8
RUN curl -LO 'http://download.oracle.com/otn-pub/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dcbf/jdk-8u151-linux-x64.rpm' -H 'Cookie: oraclelicense=accept-securebackup-cookie'
RUN rpm -i jdk-8u151-linux-x64.rpm
RUN rm jdk-8u151-linux-x64.rpm

ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin
# default -> /usr/java/latest， latest -> /usr/java/jdk1.7.0_71
RUN rm /usr/bin/java && ln -s $JAVA_HOME/bin/java /usr/bin/java 

### TODO Download HBase & Configure EVN variables
RUN curl -s http://apache.claz.org/hbase/stable/hbase-1.2.6-bin.tar.gz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s ./hbase-1.2.6 hbase

ENV HBASE_PREFIX /usr/local/hbase
# Configure the JAVA_HOME for HBase again
RUN sed -i '/^# export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/java/default\n:' $HBASE_PREFIX/conf/hbase-env.sh
# ENV HADOOP_COMMON_HOME /usr/local/hadoop
# ENV HADOOP_HDFS_HOME /usr/local/hadoop
# ENV HADOOP_MAPRED_HOME /usr/local/hadoop
# ENV HADOOP_YARN_HOME /usr/local/hadoop
# ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop
# ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop
# 
# RUN sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop/:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
# RUN . $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

# RUN mkdir $HADOOP_PREFIX/input
# RUN cp $HADOOP_PREFIX/etc/hadoop/*.xml $HADOOP_PREFIX/input

# TODO Add cinfiguration file for HBase to distributed on a 3 machine cluster
ADD hbase-site.xml  $HBASE_PREFIX/conf/hbase-site.xml

#### TODO Add bootstrap script to change something when container starts
ADD bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh
#### TODO Add it back 
ENV BOOTSTRAP /etc/bootstrap.sh
###
# workingaround docker.io build error
# RUN ls -la /usr/local/hadoop/etc/hadoop/*-env.sh
# RUN chmod +x /usr/local/hadoop/etc/hadoop/*-env.sh
# RUN ls -la /usr/local/hadoop/etc/hadoop/*-env.sh

# Create folder for data if not exists
RUN mkdir -p $HBASE_PREFIX/tmp/hbase_data
RUN mkdir -p $HBASE_PREFIX/tmp/zookeeper_data

### Add SSH Configuration
ADD ssh_config /root/.ssh/config 
RUN chmod 600 /root/.ssh/config 
RUN chown root:root /root/.ssh/config 


# Maven
# maven.sh script is loaded during bootstrap
RUN curl -s http://www-eu.apache.org/dist/maven/maven-3/3.5.0/binaries/apache-maven-3.5.0-bin.tar.gz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s apache-maven-3.5.0  maven
# ADD maven.sh /etc/profile.d/maven.sh
ENV M2_HOME /usr/local/maven
ENV M2 $M2_HOME/bin
ENV PATH $M2:$PATH

# YCSB from github repo
RUN git clone https://github.com/brianfrankcooper/YCSB.git /usr/local/YCSB
ENV YCSB_PREFIX /usr/local/YCSB

###
# fix the 254 error code
RUN sed  -i "/^[^#]*UsePAM/ s/.*/#&/"  /etc/ssh/sshd_config
RUN echo "UsePAM no" >> /etc/ssh/sshd_config
RUN echo "Port 21222" >> /etc/ssh/sshd_config


RUN service sshd start 

WORKDIR /usr/local/hbase

# HDFS Default Ports
# Ref: https://ambari.apache.org/1.2.3/installing-hadoop-using-ambari/content/reference_chap2_4.html
# HMaster, hbase.master.port
EXPOSE 60000
# HMaster Info Web UI (http), hbase.master.info.port
EXPOSE 60010
# Region Server, hbase.regionserver.port
EXPOSE 60020
# Region Server Web UI(http), hbase.regionserver.info.port
EXPOSE 60030

# Zookeeper
# hbase.zookeeper.peerport
EXPOSE 2888
# hbase.zookeeper.leaderport
EXPOSE 3888
# hbase.zookeeper.property.clientPort
EXPOSE 2181

# ssh
EXPOSE 21222

CMD ["/etc/bootstrap.sh", "-d"] # Run this inside container
