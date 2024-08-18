# Instance type
variable "instance_type" {
  default = {
    "staging" = "t2.micro"
  }
  description = "Type of the instance"
  type        = map(string)
}

# Default tags
variable "default_tags" {
  default = {
    "Owner" = "Group8"
    "App"   = "Web"
  }
  type        = map(any)
  description = "Default tags to be appliad to all AWS resources"
}

# Prefix to identify resources
variable "prefix" {
  default     = "group8-staging"
  type        = string
  description = "Name prefix"
}


# Variable to signal the current environment 
variable "env" {
  default     = "staging"
  type        = string
  description = "Deployment Environment"
}

# WebServer Names
variable "webServerNames" {
  type    = list(string)
  default = ["webServer1", "webServer2", "webServer3", "webServer4", "webServer5", "webServer6"]
}
