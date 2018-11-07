# OL_PACEMAKER
In this how-to guide I’ll describe the configuration steps to setup a three node Oracle Linux Pacemaker and Corosync cluster with a running apache server on the nodes. This configuration can be used setup the three node demos of the cluster software.
I use the following software:
•	http://yum.oracle.com/boxes/oraclelinux/ol74/ol74.box
•	
Prerequisites
1.	Install Oracle VM VirtualBox
2.	Install Vagrant
Getting started
1.	Clone this repository git clone https://github.com/Gandalf3100/OL_PACEMAKER
2.	Change into the desired software folder
3.	Follow the README.md instructions inside the folder
I run this deployment on a laptop where I have installed Vagrant and VirtualBox. This how-to will run on every developer platform (Windows, MacOS or Linux). But do not hesitate to use this how-to on any virtualization platform (Oracle Linux VMs based on KVM or VMware) or on bare-metal Oracle Linux servers in your datacenter network.
In this deployment I use the standard IP addresses that is configured in Vagrantfile, you can add these addresses to your local hosts file on the laptop, or just use the IP.
192.168.56.101  cluster-node1
192.168.56.102  cluster-node2
192.168.56.103  cluster-node2
# Available IPadress for the Apache servers 
192.168.56.104  Apache-webserver
Installation steps
Open a command-line in the directory where you download the git clone, change directory to OL_PACEMAKER. Here just need to run vagrant up, and the installation will take approx. 10 min, and the cluster will be up and running.
To check your setup is running, open a browser on your laptop and access the http://192.168.56.104
You should see a webpage with:
Demo of a three node cluster. cluster-node1
To test your cluster try to kill the vbox image with cluster-node1 and you will see the webserver is now answering from Demo of a three node cluster. cluster-node2 
To understand what is happening, I have add a lot of comments to the bootstrap.sh file that one can read.
