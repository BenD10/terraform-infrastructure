variable "vpc_cidr" {
  description = "CIDR block to use for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks to use for public subnets."
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks to use for private subnets."
  type        = list(string)
  default     = ["10.0.100.0/24", "10.0.101.0/24", "10.0.102.0/24"]
}
