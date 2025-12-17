# coalfire-terraform-challenge
Project Test for Coalfire
Coalfire Terraform Challenge
Solution Overview
This proof-of-concept deploys an Azure environment using Terraform with proper network segmentation and security controls. The environment hosts a basic web server behind a load balancer, with supporting infrastructure and access restrictions.
Architecture

Virtual Network: 10.0.0.0/16 with 4 subnets:

web (10.0.1.0/24)
management (10.0.2.0/24)
application (10.0.3.0/24)
backend (10.0.4.0/24)


Compute:

2 Linux VMs (Ubuntu 22.04 LTS) in an Availability Set in the web subnet
1 Linux VM in the management subnet


Security:

NSG for web subnet: allows HTTP from Load Balancer, SSH only from management subnet
NSG for management subnet: allows SSH only from a specific IP


Storage:

1 Storage Account (GRS) with containers:

terraformstate
weblogs


Accessible only from the management subnet


Load Balancer:

Public Standard LB distributing traffic to web VMs
