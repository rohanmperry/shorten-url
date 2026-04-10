variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "shorten-url"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner tag for all resources"
  type        = string
  default     = "Jay"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_nat_gateway" {
  description = "Whether to create a NAT Gateway"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "create_short_url_zip_path" {
  description = "Path to the create_short_url Lambda zip"
  type        = string
  default     = "../bin/create_short_url.zip"
}

variable "redirect_zip_path" {
  description = "Path to the redirect zip"
  type        = string
  default     = "../bin/redirect.zip"
}
