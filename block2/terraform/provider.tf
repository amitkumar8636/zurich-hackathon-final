terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"

    }
  }
#   backend "s3" {
#     bucket         = "hackathon-bucket-name"
#     key            = "state/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terragrunt-state"
#   }
}



# Configure the AWS Provider
provider "aws" {
  region  = "us-east-1"
  profile = "hack"
}