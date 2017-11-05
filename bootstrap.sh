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
# only run from machine 03
[ $HOSTNAME == "CSE-Hcse101423D" ] && $HBASE_PREFIX/bin/start-hbase.sh 
# sleep 30 
# [ $HOSTNAME == "CSE-Hcse101423D" ] && $HBASE_PREFIX/bin/stop-hbase.sh 
# sleep 30
# [ $HOSTNAME == "CSE-Hcse101423D" ] && $HBASE_PREFIX/bin/start-hbase.sh 

cd $YCSB_PREFIX
# [ $HOSTNAME == "CSE-Hcse101423D" ] && $YCSB_PREFIX/run_YCSB.sh 

# Keep container Running while run in background
if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
