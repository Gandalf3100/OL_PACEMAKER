#!/bin/sh

die() {
  printf '%s\n\n' "$1" >&2
  printf 'Usage: bootstrap -m | -n\n'
  printf '       -m : cluster master server\n'
  printf '       -n : cluster node server\n'
  exit 1
}

################################################################################
# Specify environment settings
################################################################################

# Set up proxy 
# echo "proxy=YOUR PROXY" >>/etc/yum.conf

################################################################################
# Fix /etc/hosts
################################################################################

sed 's/127\.0\.0\.1.*cluster-node1.*/192.168.56.101 cluster-node1/' -i /etc/hosts
sed 's/127\.0\.0\.1.*cluster-node2.*/192.168.56.102 cluster-node2/' -i /etc/hosts
sed 's/127\.0\.0\.1.*cluster-node3.*/192.168.56.103 cluster-node3/' -i /etc/hosts
sed '$ a 192.168.56.101 cluster-node1' -i /etc/hosts
sed '$ a 192.168.56.102 cluster-node2' -i /etc/hosts
sed '$ a 192.168.56.103 cluster-node3' -i /etc/hosts


################################################################################
# Post installation customization
################################################################################

#echo "Post OS installation customization"

NODE_TYPE=""

while getopts ":mn" opt; do
  case $opt in
    m) NODE_TYPE="master"
      echo "This will connect the three cluster nodes "
      ;;
    n) NODE_TYPE="node"
      echo "This will be a cluster node"
      ;;
    \?)
      die "Invalid option: -$OPTARG"
      ;;
  esac
done

if [ "$NODE_TYPE" == "" ]; then
  die "Missing option: specify type of node."
fi

################################################################################
# Installing PaceMaker, Cronosync, lsscsi and httpd
################################################################################

yum -y install yum-utils
yum -y install lsscsi
yum -y install httpd
yum -y install pcs fence-agents-all 

#mkdir ~/.ssh
#cp /vagrant/id_rsa* ~/.ssh
#cp /vagrant/id_rsa.pub ~/.ssh/authorized_keys
#echo StrictHostKeyChecking no >>/etc/ssh/ssh_config

################################################################################
# Creating an index.html file on the nodes (Not currently using shared storage)
################################################################################

touch /var/www/html/index.html;
echo '<h1 style="color: #5e9ca0;">Demo of a three node  cluster. <span style="color: #2b2301;">' > /var/www/html/index.html;
hostname >> /var/www/html/index.html;
echo '</span> </h1>' >> /var/www/html/index.html;
chmod 755 /var/www/html/index.html;


###############################################################################
# DISABLING FIREWALL
###############################################################################

systemctl disable firewalld
systemctl stop firewalld

###############################################################################
# ENABLING pcsd and setting password for cluster
###############################################################################

systemctl enable --now pcsd
echo password | passwd --stdin hacluster


###############################################################################
# Connecting all the three clusters nodes  
###############################################################################

if [ "$NODE_TYPE" == "master" ]; then
 printf 'Enabling the ´Demo Cluster on the three nodes \n';
 pcs cluster auth -u hacluster -p password cluster-node1 cluster-node2 cluster-node3;
 pcs cluster setup --start --name democluster cluster-node1 cluster-node2 cluster-node3;
 pcs cluster status;
 systemctl status corosync -l;
 corosync-quorumtool;

 ############################################################################ 
 # setting stonith-enable to false
 ############################################################################
 pcs property set stonith-enabled=false;
 
 ############################################################################
 # First Resource,Setting up a High Availeble IPadress for the Apache servers
 # Then Setting the apache services and defining a apache group, with the two
 # new resources are in. 
 ############################################################################

 pcs resource create apache-ip IPaddr2 ip=192.168.56.104 cidr_netmask=24;
 pcs resource create apache-service apache;
 pcs resource group add apache-group apache-ip;
 pcs resource group add apache-group apache-service;
fi
