#!/bin/bash

read -p "Have you format and restart hdfs? (y/n): " isformat
[ $isformat == "y" ] && docker run -it --net=host \
  -p 60000:60000 -p 60010:60010 -p 60020:60020 -p 60030:60030 \
  -p 16000:16000 -p 16010:16010 -p 16020:16020 -p 16030:16030 \
  -p 16012:16012 -p 16022:16022 -p 16032:16032 \
  -p 16014:16014 -p 16024:16024 -p 16034:16034 \
  -p 16200:16200 -p 16300:16300 \
  -p 2888:2888 -p 3888:3888 -p 2181:2181 \
  -p 21222:21222 \
  --mount source=pci_experiment,target=/usr/local/pci_experiment_volume \
  --name hbase_distributed \
  pls331/centos:hbase-1.2.6-dist /etc/bootstrap.sh -bash
