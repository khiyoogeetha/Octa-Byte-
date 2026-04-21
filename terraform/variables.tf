variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "devops-assignment"
}

variable "environment" {
  description = "Environment (e.g., staging, prod)"
  type        = string
  default     = "staging"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "Private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "db_password" {
  description = "Password for PostgreSQL RDS"
  type        = string
  sensitive   = true
  default     = "DevOpsSecurePass123!" # Default given just for easy happy path testing
}
