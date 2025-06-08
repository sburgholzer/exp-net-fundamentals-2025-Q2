# Projects Done and things Learned in Week 1

### Setup Cloud Environment
- This was to setup the VPC in AWS (instructor used AWS and as an AWS user myself, I went AWS as well), for the bootcamp.
- We also created a key (or used existing key) for access to our EC2 instances.
- Launched a Windows Server EC2 instance that will be needed.
- Created an ENI in the private subnet and attached it to the windows instance so it has two ENIs now.
- Launched an Ubuntu Server EC2 instance, I used the existing SG, but updated it to allow SSH from my IP. Created another private ENI and attached it to the Ubuntu instance.
- Launched a Redhat Server EC2 instance similar to Ubuntu server.
- Associated Elastic IPs to each server for use during the bootcamp, will release them back to AWS when bootcamp is over.
- **Note**: This was clickops, meaning all done in AWS Web Console

### [Automate VPC Deployment with CFN](../projects/env_automation/Journal.md)

### IP Address Management

#### Windows
- Showed how to get to the network settings via Control panel
- Went over the Network Connection Details screen
- Went over how to manually set the device's IP address (mostly done for on-prem devices)
- Went over the ipconfig command (including /all)