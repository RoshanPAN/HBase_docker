# Run this Script in the folder contains docker file
# Make sure 

# Allow ports in firewall
# HMaster, hbase.master.port
ufw allow 60000
ufw allow 16010
ufw allow 16020
ufw allow 16030
ufw allow 16012
ufw allow 16022
ufw allow 16032
ufw allow 16014
ufw allow 16024
ufw allow 16034

# HMaster Info Web UI (http), hbase.master.info.port
ufw allow 60010
# Region Server, hbase.regionserver.port
ufw allow 60020
ufw allow 16200
# Region Server Web UI(http), hbase.regionserver.info.port
ufw allow 60030
ufw allow 16300

# Zookeeper
# hbase.zookeeper.peerport
ufw allow 2888
# hbase.zookeeper.leaderport
ufw allow 3888
# hbase.zookeeper.property.clientPort
ufw allow 2181

# ssh
ufw allow 21222

# confirm the permission of folders for ssh
chmod go-w ~/
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

# confirm the ownership of folders for ssh
chown pls331pci ~/
chown pls331pci ~/.ssh

# Copy ssh keys into the context of the build
cp ~/.ssh/id_rsa . && \
  cp ~/.ssh/id_rsa.pub . && \
  cp ~/.ssh/authorized_keys . && \
  cp ~/.ssh/known_hosts . && \
  echo ">>> ssh keys copied to the building context"

# Build Docker Image && Create Contrainer from Image
docker build -t="pls331/centos:hbase-1.2.6-dist" . && \
docker run -it --net=host \
  -p 60000:60000 -p 60010:60010 -p 60020:60020 -p 60030:60030 \
  -p 16010:16010 -p 16020:16020 -p 16030:16030 \
  -p 16012:16012 -p 16022:16022 -p 16032:16032 \
  -p 16014:16014 -p 16024:16024 -p 16034:16034 \
  -p 16200:16200 -p 16300:16300 \
  -p 2888:2888 -p 3888:3888 -p 2181:2181 \
  -p 21222:21222 \
  pls331/centos:hbase-1.2.6-dist /etc/bootstrap.sh -bash
