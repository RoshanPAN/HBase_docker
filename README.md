# HBase_docker
This is an docker image/Dockerfile for running a 3 machine **Hbase** cluster.
**YCSB** is included as well.
- HBase version: 1.2.6

# Some ENV Variables in container
- `$HBASE_PREFIX`: path to HBASE
- `$YCSB_PREFIX`: path to YCSB
- `$EXPERIMENT`: path to the scripts of modify YCSB to record throughput and other scripts

# Steps to use the container in the experiement
###### Host Machine Configuration
1. Modify the `/etc/hosts` file on host machine to be like this:
  ```
  164.107.119.22	localhost
  164.107.119.22	CSE-Hcse101423D

  # The following lines are desirable for IPv6 capable hosts
  ::1     ip6-localhost ip6-loopback
  fe00::0 ip6-localnet
  ff00::0 ip6-mcastprefix
  ff02::1 ip6-allnodes
  ff02::2 ip6-allrouters
  164.107.119.20       machine01
  164.107.119.21       machine02
  164.107.119.22       machine03
  ```
  > Container seems to use the host machine's `/etc/hosts` file.
2. Have the 3 machines using the same SSH public and private key.
  > Dockerfile will copy their host machine's public & private key into the container, so that the container could have no password SSH login with each other.


###### Use the Container
0. Create the volume to be mounted into container
  `docker volume create pci_experiment`
  ``
1. **Format the HDFS** 
  > There is a script in HDFS container to do this. `$HADOOP_PREFIX/restart-hdfs.sh`)

2. **Start Container**
  ```
  cd path/to/Hbase_docker
  ./prepare_host.sh
  ./run_image.sh
  ```

3. **Start Hbase** `bin/start-hbase.sh`
  > Hbase is not very stable. It's easy to have problem starting up.
  > Try with writing something into a splitted table. 
  > Try with running workloada. 

4. **Add a table for YCSB from** `bin/hbase shell`
  ```
  # inside Hbase shell
  n_splits = 200
  create 'usertable', 'family', {SPLITS => (1..n_splits).map {|i| \"user#{1000+i*(9999-1000)/n_splits}\"}}
  ```
5. **Run YCSB with** `workloady`
    - Replace 2 source file in YCSB with the ones we modified and put the workloady into `$YCSB_PREFIX/workloads` folder
      `cd $EXPERIMENT`
      `./modifyYCSB_new.sh`
    - Load YCSB data into HBase
      `./loadYCSB.sh`
    - Start YCSB
      `./startYCSB.sh`


# Move the YCSB logged throughput data out of container
 - Volume have been created for docker in `prepare_host.sh`.
 - 
Reference: [Data Management in Docker](https://docs.docker.com/engine/admin/volumes/#more-details-about-mount-types) 

# Some HBase Shell Command for testing
```bash
# Hbase shell test command
create 'test', 'cf'

list 'test'

put 'test', 'row1', 'cf:a', 'value1'

put 'test', 'row2', 'cf:b', 'value2'

put 'test', 'row3', 'cf:c', 'value3'

scan 'test'

get 'test', 'row1'

disable 'test'

enable 'test'

disable 'test'

drop 'test'

n_splits = 200

create 'usertable', 'family', {SPLITS => (1..n_splits).map {|i| "user#{1000+i*(9999-1000)/n_splits}"}}

put 'usertable', 'row1', 'family:a', 'value1'

# Run the workloada using ycsb (must be in YCSB folder)
cd $YCSB_PREFIX
bin/ycsb load hbase12 -P workloads/workloada -cp $HBASE_PREFIX/conf -p table=usertable -p columnfamily=family
bin/ycsb run hbase12 -P workloads/workloada -cp $HBASE_PREFIX/conf -p table=usertable -p columnfamily=family
```

# Link
- HBase would be run on top of HDFS. My HDFS docker container build files is [here](https://github.com/RoshanPAN/hadoop_docker).
- pci_experiment repository is [here](https://github.com/RoshanPAN/pci_experiment)
- Logging script of the linux system performance metrics is [here](https://github.com/guihaomin/getSysInfo)
