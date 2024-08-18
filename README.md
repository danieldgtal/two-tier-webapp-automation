# ACS730 Final Project: Two-Tier Static Web Application Hosting and Configuration Solution
## Overview
This project demonstrates the deployment of a two-tier static web application on AWS using Terraform for infrastructure provisioning, Ansible for configuration management, and GitHub Actions for CI/CD automation. The infrastructure consists of 6 VMs across 4 public and 2 private subnets in different availability zones.
## Architecture
<ul>
  <li>VPC and Subnets</li>
  <li>Virtual Machines</li>
  <li>NAT Gateways</li>
  <li>Application Load Balancer</li>
</ul>

## Configuration Management
<ul>
  <li>Check Connectivity</li>
  <li>Verify service status</li>
  <li>Applying updates and patches</li>
  <li>Enabling web servers</li>
</ul>

## Automation and security
<ul>
  <li>GitHub Actions</li>
  <li>Terraform Modulesl</li>
</ul>
 
## Terraform Deployment
Navigate to the terraform directory and initialize the workspace
Apply the terraform configurations to provision the VPC, subnts, NAT Gateway, and VMs.
<code>
  cd terraform/
  terraform init
  terraform apply
</code>
## Ansible Configuration
<ul>
  <li>Use Ansible playbooks to configure the remaining web servers</li>
  <li>Example command to run ansible playbooks</li>
</ul>
<code>
  ansible-playbook -i inventory/hosts playbooks/webserver.yml
</code>

## Submission Artifacts
<ul>
  <li>Terraform code and configurations</li>
  <li>Ansible playbooks and inventory files</li>
  <li>GitHub Actions workflows</li>
  <li>Any additional documentation required</li>
</ul>

## License
This project is licensed under the MIT License.
=======
# ACS730 Summer 2024 Final Project Deployment
## Overview
This README provides instructions to successfully deploy the architecture depicted in the provided project diagram. The architecture includes multiple EC2 instances, an Auto Scaling group, a load balancer, and S3 buckets for storing Terraform state and serving images to the web servers.
## Prerequisites
<ul>
  <li>S3 Buckets</li>
  <li>SSH Keypair</li>
  <li>GitHub Repo</li>
</ul>
