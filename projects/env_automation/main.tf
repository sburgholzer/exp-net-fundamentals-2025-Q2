# Backend Configuration
terraform {
  required_version = ">= 1.10.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket = "scott-iac-backends"
    key    = "networking-bootcamp/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    use_lockfile = true
  }
}

# AWS Provider Configuration
provider "aws" {
  region = "us-east-1"
  
  default_tags {
    tags = {
      Project     = "networking-bootcamp"
      Environment = "lab"
      ManagedBy   = "opentofu"
    }
  }
}

# Local values for consistent naming
locals {
  name_prefix = "networking-bootcamp"
  
  common_tags = {
    Project     = "networking-bootcamp"
    Environment = "lab"
    ManagedBy   = "opentofu"
  }
}

# Data source to get the first available AZ
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.200.123.0/24"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-igw"
  })
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.200.123.0/25"  # First half: 10.200.123.0-127
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-subnet"
    Type = "Public"
  })
}

# Private Subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.200.123.128/25"  # Second half: 10.200.123.128-255
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-subnet"
    Type = "Private"
  })
}

# Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-rt"
  })
}

# Route Table Association for Public Subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Route Table for Private Subnet (no routes to internet - no NAT gateway)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-rt"
  })
}

# Route Table Association for Private Subnet
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
# Data source to get current public IP
data "http" "current_ip" {
  url = "https://ipv4.icanhazip.com"
}

# Data sources for AMIs
data "aws_ami" "windows_2025" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["Windows_Server-2025-English-Full-Base-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "redhat" {
  most_recent = true
  owners      = ["309956199498"] # Red Hat
  
  filter {
    name   = "name"
    values = ["RHEL-*-x86_64-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group for EC2 instances
resource "aws_security_group" "ec2_sg" {
  name_prefix = "${local.name_prefix}-ec2-sg"
  vpc_id      = aws_vpc.main.id

  # Allow all traffic from within VPC
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  # RDP access from user's IP only
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.current_ip.response_body)}/32"]
    description = "RDP access from user IP"
  }

  # SSH access from user's IP only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.current_ip.response_body)}/32"]
    description = "SSH access from user IP"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ec2-sg"
  })
}

# ENIs for public subnet
resource "aws_network_interface" "windows_public_eni" {
  subnet_id       = aws_subnet.public.id
  security_groups = [aws_security_group.ec2_sg.id]

  tags = merge(local.common_tags, {
    Name = "windows-public-subnet-eni"
  })
}

resource "aws_network_interface" "ubuntu_public_eni" {
  subnet_id       = aws_subnet.public.id
  security_groups = [aws_security_group.ec2_sg.id]

  tags = merge(local.common_tags, {
    Name = "ubuntu-public-subnet-eni"
  })
}

resource "aws_network_interface" "redhat_public_eni" {
  subnet_id       = aws_subnet.public.id
  security_groups = [aws_security_group.ec2_sg.id]

  tags = merge(local.common_tags, {
    Name = "redhat-public-subnet-eni"
  })
}

# ENIs for private subnet
resource "aws_network_interface" "windows_private_eni" {
  subnet_id       = aws_subnet.private.id
  security_groups = [aws_security_group.ec2_sg.id]

  tags = merge(local.common_tags, {
    Name = "windows-private-subnet-eni"
  })
}

resource "aws_network_interface" "ubuntu_private_eni" {
  subnet_id       = aws_subnet.private.id
  security_groups = [aws_security_group.ec2_sg.id]

  tags = merge(local.common_tags, {
    Name = "ubuntu-private-subnet-eni"
  })
}

resource "aws_network_interface" "redhat_private_eni" {
  subnet_id       = aws_subnet.private.id
  security_groups = [aws_security_group.ec2_sg.id]

  tags = merge(local.common_tags, {
    Name = "redhat-private-subnet-eni"
  })
}

# Elastic IPs for public ENIs
resource "aws_eip" "windows_eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.windows_public_eni.id
  associate_with_private_ip = aws_network_interface.windows_public_eni.private_ip

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-windows-eip"
  })
}

resource "aws_eip" "ubuntu_eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.ubuntu_public_eni.id
  associate_with_private_ip = aws_network_interface.ubuntu_public_eni.private_ip

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ubuntu-eip"
  })
}

resource "aws_eip" "redhat_eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.redhat_public_eni.id
  associate_with_private_ip = aws_network_interface.redhat_public_eni.private_ip

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-redhat-eip"
  })
}

# EC2 Instances
resource "aws_instance" "windows_server" {
  ami           = data.aws_ami.windows_2025.id
  instance_type = "t3.large"
  key_name      = "networkingbootcampkey"

  network_interface {
    network_interface_id = aws_network_interface.windows_public_eni.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.windows_private_eni.id
    device_index         = 1
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-windows-server"
    OS   = "Windows Server 2025"
  })
}

resource "aws_instance" "ubuntu_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  key_name      = "networkingbootcampkey"

  network_interface {
    network_interface_id = aws_network_interface.ubuntu_public_eni.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.ubuntu_private_eni.id
    device_index         = 1
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ubuntu-server"
    OS   = "Ubuntu"
  })
}

resource "aws_instance" "redhat_server" {
  ami           = data.aws_ami.redhat.id
  instance_type = "t2.medium"
  key_name      = "networkingbootcampkey"

  network_interface {
    network_interface_id = aws_network_interface.redhat_public_eni.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.redhat_private_eni.id
    device_index         = 1
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-redhat-server"
    OS   = "Red Hat Enterprise Linux"
  })
}
