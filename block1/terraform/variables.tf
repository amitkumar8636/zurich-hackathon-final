variable "name" {
  type = string
  default = "Hackathon"
  
}
variable "hackathon_tags" {
    type = map(string)
    default = {
      Name        = "Zurich-Hackathon-resources"
      Environment = "Dev"
    }
    
  
}

variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
 
variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "hack_key_pairs" {
    type = list(string)
    default = ["hackathon.pub","hack2.pub"]
  
}



variable "ami-filter" {
  type = list(string)
  description = "Incase of Secuirty Hardened AMI, Please put the AMI name  partially to get it updated"
  default = ["*al2023-ami-2023.1.20230705.0-kernel*"]
}

variable "total_key_pairs" {
  default = 2
  description = "Total no of key pairs created so exactly the instance will be created as per problem"
  type = number
  
}

variable "ec2_instance_type" {
  type = string
  default = "t3.micro"
  description = "EC2 instance type bases on size/cpu/memory"
  
}


variable "vpc_cidr" {
  default = "10.0.0.0/16"
  type = string  
}

variable "public_subnet" {
  default = "10.0.1.0/24"
  type = string
  
}
variable "private_subnet" {
  default = "10.0.4.0/24"
  type = string  
}

variable "public_cidr" {
  type = list(string)
  default = ["0.0.0.0/0"]
}

# variable "rules" {
#   type = list(tuple( object))
#   default = [
#   {
#     protocol = "tcp"
#     port = 22
#     cidr = ["10.0.0.0/8"],
#   },
#   {
#     protocol = "tcp"
#     port = 443
#     cidr = ["10.0.0.0/8"]
#   },
#   {
#     protocol = "tcp"
#     port = 1337
#     cidr = ["10.0.0.0/8"]
#   },
#   {
#     protocol = 0
#     port = 3035
#     cidr = ["10.0.0.0/8"]
#   }
# ]
# } 