variable "aws_region" {
  description = "Target AWS region for deploying infrastructure"
  type        = string
  default     = "ap-south-1" # Mumbai (can be changed to us-east-1)
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "Production"
}

variable "vpc_cidr" {
  description = "CIDR block for the custom VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of Availability Zones for high availability distribution"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks allocated to public web subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks allocated to isolated private database/backend subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}
