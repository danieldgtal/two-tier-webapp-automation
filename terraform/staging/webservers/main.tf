# Terraform Config file (main.tf). This has provider block (AWS) and config for provisioning one EC2 instance resource.  

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.27"
    }
  }

  required_version = ">=0.14"
}
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

data "terraform_remote_state" "network" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = "acsproject-staging"                // Bucket from where to GET Terraform State
    key    = "dev/network/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                     // Region where bucket created
  }
}

# Data source for AMI id
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

# Define tags locally
locals {
  default_tags = merge(var.default_tags, { "env" = var.env })
  name_prefix  = "${var.prefix}-${var.env}"

}

# Adding SSH  key to instance
resource "aws_key_pair" "group8_staging" {
  key_name   = var.prefix
  public_key = file("~/.ssh/${var.prefix}.pub")
}

# VM1 | Webserver1 | Public Subnet1
resource "aws_instance" "webServer1" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.group8_staging.key_name
  security_groups             = [data.terraform_remote_state.network.outputs.ssh_http_sg]
  subnet_id                   = data.terraform_remote_state.network.outputs.public_subnet_ids[0] # Public Subnet 1
  associate_public_ip_address = true

  user_data = templatefile("./install_httpd.sh.tpl",
    {
      env           = upper(var.env),
      prefix        = upper(var.prefix)
      instance_name = upper(var.webServerNames[0])
    }
  )

  root_block_device {
    encrypted = var.env == "test" ? true : false
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-webserver1"
    }
  )
}

# VM3 | Webserver3 | Public Subnet3
resource "aws_instance" "webServer3" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.group8_staging.key_name
  security_groups             = [data.terraform_remote_state.network.outputs.ssh_http_sg]
  subnet_id                   = data.terraform_remote_state.network.outputs.public_subnet_ids[2] # Public Subnet 3
  associate_public_ip_address = true

  user_data = templatefile("./install_httpd.sh.tpl",
    {
      env           = upper(var.env),
      prefix        = upper(var.prefix)
      instance_name = upper(var.webServerNames[2])
    }
  )

  root_block_device {
    encrypted = var.env == "test" ? true : false
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-webserver3"
    }
  )
}

# VM2 | Webserver2 | Public Subnet2
resource "aws_instance" "webServer2" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.group8_staging.key_name
  security_groups             = [data.terraform_remote_state.network.outputs.ssh_http_sg]
  subnet_id                   = data.terraform_remote_state.network.outputs.public_subnet_ids[1]  # Public Subnet 2
  associate_public_ip_address = true

  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-webserver2-bastion"
    }
  )
}

# VM4 | Webserver4 | Public Subnet4
resource "aws_instance" "webServer4" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.group8_staging.key_name
  security_groups             = [data.terraform_remote_state.network.outputs.ssh_http_sg]
  subnet_id                   = data.terraform_remote_state.network.outputs.public_subnet_ids[3]  # Public Subnet 2
  associate_public_ip_address = true

  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-webserver4"
    }
  )
}


resource "aws_instance" "webServer5" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.group8_staging.key_name
  security_groups             = [data.terraform_remote_state.network.outputs.ssh_only]
  subnet_id                   = data.terraform_remote_state.network.outputs.private_subnet_ids[0]  # Private Subnet 1
  associate_public_ip_address = false

  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-webServer5"
    }
  )
}


resource "aws_instance" "vm6" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.group8_staging.key_name
  security_groups             = [data.terraform_remote_state.network.outputs.ssh_only]
  subnet_id                   = data.terraform_remote_state.network.outputs.private_subnet_ids[1]  # Private Subnet 2
  associate_public_ip_address = false

  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-VM6"
    }
  )
}


resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.terraform_remote_state.network.outputs.ssh_http_sg]
  subnets = [
    data.terraform_remote_state.network.outputs.public_subnet_ids[0],
  data.terraform_remote_state.network.outputs.public_subnet_ids[2]]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "wbserver1_wbserver3" {
  name     = "alb-targetgroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_id
}

resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wbserver1_wbserver3.arn
  }
}


# AUTO SCALING GROUP FAILED DUE TO USER PRIVILEDGE
# resource "aws_launch_configuration" "scalegroup_lc" {
#   name          = "scalegroup-lc"
#   image_id      = data.aws_ami.latest_amazon_linux.id
#   instance_type = lookup(var.instance_type, var.env)

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_autoscaling_group" "autoscalinggrp1_3" {
#   desired_capacity = 2
#   max_size         = 3
#   min_size         = 2
#   vpc_zone_identifier = [
#     data.terraform_remote_state.network.outputs.public_subnet_ids[0],
#     data.terraform_remote_state.network.outputs.public_subnet_ids[1],
#     data.terraform_remote_state.network.outputs.public_subnet_ids[2]
#   ]

#   launch_configuration = aws_launch_configuration.scalegroup_lc.id
#   target_group_arns    = [aws_lb_target_group.wbserver1_wbserver3.arn]

#   tag {
#     key                 = "Name"
#     value               = "webserver-asg"
#     propagate_at_launch = true
#   }
# }
