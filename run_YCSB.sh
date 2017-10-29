#!/bin/bash
loadname="workloadmy"
$YCSB_PREFIX/bin/ycsb load hbase12 -P workloads/${loadname} -cp /usr/local/hbase-1.2.6/conf -p table=usertable -p columnfamily=family
echo "run ${loadname}"

cd $YCSB_PREFIX
$YCSB_PREFIX/bin/ycsb run hbase12 -P workloads/${loadname} -cp /usr/local/hbase-1.2.6/conf -p table=usertable -p columnfamily=family
echo "run ${loadname}"
