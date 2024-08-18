# Default Tags
variable "defaultTags" {
  default = {
    "Owner" = "Group8",
    "App"   = "Web"
  }
  type        = map(any)
  description = "Default tags to be applied to all AWS resources"
}

# Four Availability Zones
variable "availabilityZones" {
  description = "List of Availability Zones to create resources in"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
}

# Name Prefix
variable "prefix" {
  type        = string
  default     = "group8-prod"
  description = "Name prefix"
}

# Provision 4 Public Subnets in Custom VPC
variable "publicSubnetCidrs" {
  default = [
    "10.1.1.0/24",
    "10.1.2.0/24",
    "10.1.3.0/24",
    "10.1.4.0/24"
  ]
  type        = list(string)
  description = "Public Subnet CIDRs"
}

# Provision 2 Private Subnets in Custom VPC
variable "privateSubnetCidrs" { # New variable for private subnets
  default = [
    "10.1.5.0/24",
    "10.1.6.0/24"
  ]
  type        = list(string)
  description = "Private Subnet CIDRs"
}

# VPC CIDR Range
variable "vpcCidr" {
  default     = "10.1.0.0/16"
  type        = string
  description = "VPC to host static web site"
}

# Variable to Signal the Current Environment
variable "env" {
  default     = "Group8-prod"
  type        = string
  description = "Deployment Environment"
}
