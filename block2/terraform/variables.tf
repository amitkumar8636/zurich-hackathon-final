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

variable "app_count" {
  type = number
  default = 1
}

variable "name" {
  type = string
  default = "Hackathon"
  
}
variable "container_port" {
  default = 8000
  type = number
  
}