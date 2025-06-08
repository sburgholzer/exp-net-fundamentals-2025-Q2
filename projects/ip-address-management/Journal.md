# IP Address Management with Azure

The only thing I have ever done in Azure is EntraID and that is for my Company's Microsoft 365 Tenant directory, otherwise I have no experience with Azure. This is the first time I've spun up a VM or anything in Azure. As such, I'm taking a bit more detailed notes for this project to help me remember if I ever need to use this again!

## Steps to manually deploy and then start working on IaC
- Setup Virtual Machine in Azure
    - for availability options, for our use case in this bootcamp, we will select ```No infrastructure redundancy required```
    - for security type, ```Trusted launch virtual machines```
    - for image, ```Windows Server 2025 Datacenter Server Core - x64 Gen2```
    - left RDP port enabled
    - left disk info as default
    - in networking, ensured we had a Public IP address (the virtual network was already created for us, for me I manually had to press create new for public ip)
    - selected the option to get rid of the Public IP and NIC upon VM deletion
    - Upon telling Azure to create the VM, there is a template tab that gives us the template used to create the VM. We are able to download this.
    - Downloaded the template and put the files in [templates/vm](templates/vm/)
    - When we logged into the VM, we had command prompt only and were unsure what to do, so we deleted the resource group and decided to start fresh, but from the template.
    - We decided to use Azure Bicep which required us to convert our template.json file.
    - We do need to install the Azure CLI
        - As I am on Mac and have Homebrew I installed via Homebrew
        - ```brew update && brew install azure-cli```
        - ![](assets/azure-cli-installed.png)

## Steps to convert ARM to Bicep and deploy via Bicep


### Why use Azure Bicep over the ARM Templates?
One of the top reasons to use Bicep over the ARM template we downloaded is that Bicep gives us improved readability and maintainability. It also gives a better developer experience over ARM. There are other benefits, but for our use case for the bootcamp, these are the main two benefits of using Bicep over ARM.



### Result Screen of Manual Deployment
![](assets/azure-manual-deployment.png)