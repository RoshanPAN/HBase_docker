#!/bin/bash

: ${HBASE_PREFIX:=/usr/local/hbase}

# Add IP-Host mapping into /etc/Hosts
echo "164.107.119.20      machine01" >> /etc/hosts
echo "164.107.119.21      machine02" >> /etc/hosts
echo "164.107.119.22      machine03" >> /etc/hosts
echo "164.107.119.20      CSE-Hcse101389D" >> /etc/hosts
echo "164.107.119.21      CSE-Hcse101384D" >> /etc/hosts
echo "164.107.119.22      CSE-Hcse101423D" >> /etc/hosts



# Change the IP of loopback
cp /etc/hosts ~/hosts.new
sed -i 's/127.0.1.1/127.0.0.1/' ~/hosts.new
cp -f ~/hosts.new /etc/hosts
rm ~/hosts.new

$HBASE_PREFIX/conf/hbase-env.sh

rm /tmp/*.pid

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
# cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

service sshd start

# Start HBase
# only run from machine 0j3
# [ $HOSTNAME == "CSE-Hcse101423D" ] && $HBASE_PREFIX/bin/start-hbase.sh 
# echo "wait for hbase to start"
# echo "All setting up completed, need insert test table manully in ./hbase shell"
# echo "hbase(main):001:0> n_splits = 200 # HBase recommends (10 * number of regionservers)"
# echo "create 'usertable', 'family', {SPLITS => (1..n_splits).map {|i| \"user#{1000+i*(9999-1000)/n_splits}\"}}"
# sleep 6
echo "[Attention] If exception happened in RegionServer, then remove the WAL logs in hdfs."
echo "bin/hdfs dfs -rmr /hbase/WALs"

# [ $HOSTNAME == "CSE-Hcse101423D" ] && cd $YCSB_PREFIX && $YCSB_PREFIX/run_YCSB.sh 

# Keep container Running while run in background
if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
