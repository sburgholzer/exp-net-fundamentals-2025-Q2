# Projects Done and things Learned in Week 1

Any links lead to Journals, more generalized info in README.md for each project (more of what you are looking for in grading I believe).

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
- [A Project using Azure for IP Address Management was completed](../projects/ip-address-management/)

#### Ubuntu
- Found out ifconfig isn't really used as much anymore
- ip addr is used more these days
- MTU is maximum transmission unit - a measurement of how much data we can cram into one packet, outside of the wrapper
- Standard Ethernet Frame Header is 1500 bytes max size
- netplan is used to make persistent changes to the network interfaces.
    - it is a yaml file
    - on AWS Ubuntu it's located at /etc/netplan/50-cloud-init.yaml
    - after making changes use netplan try to test your changes, after about 2 minutes it'll revert back, so if you accidentally made a breaking change, you don't loose full networking access to your server/pc.

### [Packet Tracer Lab](../projects/packet-tracer/Journal.md)

### [Windows Networking Tools](../projects/windows-networking-tools/Journal.md)