resource "random_string" "random" {
  length = 6
  lower = true
  special = false
  numeric = false
  upper = false
}

# VPC Creation
resource "aws_vpc" "hackathon-vpc" {
 cidr_block = var.vpc_cidr
 
 tags = var.hackathon_tags
}

#Subnets========================================



resource "aws_subnet" "public_subnets" {
 vpc_id     = aws_vpc.hackathon-vpc.id
 cidr_block = var.public_subnet
 
 tags = var.hackathon_tags
}
 
resource "aws_subnet" "private_subnets" {
 vpc_id     = aws_vpc.hackathon-vpc.id
 cidr_block = var.private_subnet
 
 tags = var.hackathon_tags
}

# Internet Gateways============
resource "aws_internet_gateway" "gw" {
 vpc_id = aws_vpc.hackathon-vpc.id
 
 tags = var.hackathon_tags
}

#Route Table============

resource "aws_route_table" "second_rt" {
 vpc_id = aws_vpc.hackathon-vpc.id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.gw.id
 }
 
tags = var.hackathon_tags
}

resource "aws_route_table_association" "public_subnet_asso" {
 count = length(var.public_subnet_cidrs)
 subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
 route_table_id = aws_route_table.second_rt.id
}

#Security Groups==========================

resource "aws_security_group" "hack-sg" {
  vpc_id = aws_vpc.hackathon-vpc.id
  name = "${var.name}-SG"

#   dynamic "ingress" {
#   for_each = var.rules

#   content {
#     from_port   = var.rules.port
#     to_port     = var.rules.port
#     protocol    = var.rules.protocol
#     cidr_blocks = var.public_cidr
#   }
# }

  ingress {
    protocol  = "tcp"
    self      = true
    from_port = 0
    to_port   = 22
    cidr_blocks = var.public_cidr
  }

  ingress {
    protocol  = "tcp"
    self      = true
    from_port = 443
    to_port   = 443
    cidr_blocks = var.public_cidr
  }
  ingress {
    protocol  = "tcp"
    self      = true
    from_port = 1337
    to_port   = 1337
    cidr_blocks = var.public_cidr
  }
  ingress {
    protocol  = 0
    self      = true
    from_port = 3035
    to_port   = 3035
    cidr_blocks = var.public_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.public_cidr
  }
}

# Ec2 Resoources

data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = var.ami-filter 
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
  count = var.total_key_pairs
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key-${random_string.random.result}-${count.index}"
#   count = length(toset(var.hack_key_pairs))
  count = length(tls_private_key.pk)
  public_key = tls_private_key.pk[count.index].public_key_openssh
#   public_key = "${file("./${var.hack_key_pairs[count.index]}")}"    
  provisioner "local-exec" { # Create a "myKey.pem" to your computer!!
    command = "echo '${tls_private_key.pk[count.index].private_key_pem}' > ./key-{${random_string.random.result}-${count.index}}.pem"
  }
}

resource "aws_instance" "hackathon-webec2" {
  
  ami           = data.aws_ami.ami.id
  instance_type = var.ec2_instance_type
  associate_public_ip_address=true
  count = length(aws_key_pair.deployer) 
  key_name = aws_key_pair.deployer[count.index].key_name
  vpc_security_group_ids = [ "${aws_security_group.hack-sg.id}"]
  subnet_id = "${aws_subnet.public_subnets.id}"
  
  tags = merge(var.hackathon_tags,tomap({"Key":"key-{${random_string.random.result}-${count.index}}"}))
}