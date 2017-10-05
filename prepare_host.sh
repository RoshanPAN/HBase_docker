# Run this Script in the folder contains docker file
# Make sure 

# Allow ports in firewall
# HMaster, hbase.master.port
ufw allow 60000
# HMaster Info Web UI (http), hbase.master.info.port
ufw allow 60010
# Region Server, hbase.regionserver.port
ufw allow 60020
# Region Server Web UI(http), hbase.regionserver.info.port
ufw allow 60030

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
  -p 2888:2888 -p 3888:3888 -p 2181:2181 \
  -p 21222:21222 \
  pls331/centos:hbase-1.2.6-dist /etc/bootstrap.sh -bash
