# Projects Done in Week 1


### Setup Cloud Environment
This was to setup the VPC in AWS (instructor used AWS and as an AWS user myself, I went AWS as well), for the bootcamp.

We also created a key (or used existing key) for access to our EC2 instances.

Launced a Windows Server EC2 instance that will be needed.

Created an ENI in the private subnet and attached it to the windows inastance so it has two ENIs now.

Launched an Ubuntu Server EC2 instance, I used the existing SG, but updated it to allow SSH from my IP. Created another private ENI and attached it to the Ubuntu instance.

Launched a Redhat Server EC2 instance similar to Ubuntu server.

Associated Elastic IPs to each server for use during the bootcamp, will release them back to AWS when bootcamp is over.