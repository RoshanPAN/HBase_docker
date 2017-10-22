#!/bin/bash

: ${HBASE_PREFIX:=/usr/local/hbase}
: ${YCSB_PREFIX:=/usr/local/YCSB}

# Add IP-Host mapping into /etc/Hosts
echo "164.107.119.20      machine01" >> /etc/hosts
echo "164.107.119.21      machine02" >> /etc/hosts
echo "164.107.119.22      machine03" >> /etc/hosts

# Change the IP of loopback
cp /etc/hosts ~/hosts.new
sed -i 's/127.0.1.1/127.0.0.1/' ~/hosts.new
cp -f ~/hosts.new /etc/hosts
rm ~/hosts.new

chmod +x $HBASE_PREFIX/conf/hbase-env.sh
$HBASE_PREFIX/conf/hbase-env.sh

rm /tmp/*.pid

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
# cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

service sshd start
# Start HBase
# $HBASE_PREFIX/bin/start-hbase.sh

$HBASE_PREFIX/bin/start-hbase.sh

# YCSB
cd $YCSB_PREFIX
# 1. Load data
# bin/ycsb load hbase -P workloads/workloada -cp $HBASE_PREFIX/conf -p table=usertable -p columnfamily=family
# 2. Run wordload
# bin/ycsb run hbase -P workloads/workloada -cp $HBASE_PREFIX/conf -p table=usertable -p columnfamily=family

# Keep container Running while run in background
if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
