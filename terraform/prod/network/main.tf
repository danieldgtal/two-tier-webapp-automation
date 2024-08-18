provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# Define tags locally
locals {
  defaultTags = merge(var.defaultTags, { "env" = var.env })
}

# Create a new VPC
resource "aws_vpc" "main" {
  cidr_block       = var.vpcCidr
  instance_tenancy = "default"
  tags = merge(
    local.defaultTags, {
      Name = "${var.prefix}"
    }
  )
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge(local.defaultTags, {
    "Name" = "${var.prefix}-igw"
  })
}


# Add provisioning of 4 public subnet in the default VPC 
resource "aws_subnet" "publicSubnet" {
  count                   = length(var.publicSubnetCidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.publicSubnetCidrs[count.index] # Defines the CIDR block for the subnet from a list of CIDR blocks
  availability_zone       = var.availabilityZones[count.index] # Specifies the availability zone for the subnet from a list of availability zones
  map_public_ip_on_launch = true
  tags = merge(local.defaultTags, {
    Name = "${var.prefix}-public-subnet-${count.index + 1}"
  })
}

# Add provisioning of 2 private subnet in the default VPC 
resource "aws_subnet" "privateSubnet" {
  count             = length(var.privateSubnetCidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.privateSubnetCidrs[count.index]
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
  tags = merge(local.defaultTags, {
    Name = "${var.prefix}-private-subnet-${count.index + 1}"
  })
}


# Route table Public Subnet
resource "aws_route_table" "publicSubnetsRouteTable" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(local.defaultTags, {
    Name = "${var.prefix}-public-route-table"
  })
}

# Associate the route table with the public subnets
resource "aws_route_table_association" "publicSubnetAssociation" {
  count          = length(var.publicSubnetCidrs)
  subnet_id      = aws_subnet.publicSubnet[count.index].id
  route_table_id = aws_route_table.publicSubnetsRouteTable.id
}

# Create NAT Gateway Elastic IP
resource "aws_eip" "nat" {
  depends_on = [aws_internet_gateway.igw]
}

# Create NAT Gateway in Public Subnet 1
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.publicSubnet[0].id # Public subnet 1
  tags = merge(local.defaultTags, {
    Name = "${var.prefix}-nat-gateway"
  })
}

# Route Table for Private Subnet 1
resource "aws_route_table" "privateSubnet1" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = merge(local.defaultTags, {
    Name = "${var.prefix}-private-subnet-1-route-table"
  })
}

# Associate the Route Table with Private Subnet 1
resource "aws_route_table_association" "privateSubnet1" {
  subnet_id      = aws_subnet.privateSubnet[0].id # Private Subnet 1
  route_table_id = aws_route_table.privateSubnet1.id
}

# Security Group | Allow SSH and HTTP
resource "aws_security_group" "allowHttpSsh" {
  name        = "allow_http_ssh"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "HTTP from everywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH from everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.defaultTags, {
    "Name" = "${var.prefix}-ssh-http"
  })
}


# Security Gtroup | Allow SSH only
resource "aws_security_group" "allowSshOnly" {
  name        = "allow_ssh_only"
  description = "Allow SSH inbound traffic only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH from everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.defaultTags, {
    Name = "${var.prefix}-ssh-only"
  })
}

