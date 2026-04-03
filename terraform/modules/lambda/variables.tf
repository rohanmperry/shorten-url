variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID — used for scoping IAM policy resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to deploy Lambda into"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for Lambda VPC config"
  type        = list(string)
}

variable "base_url" {
  description = "Base URL for shortened links — updated after API Gateway is created"
  type        = string
  default     = "https://placeholder.example.com"
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "create_short_url_zip_path" {
  description = "Path to the create_short_url Lambda deployment zip"
  type        = string
  default     = "../bin/create_short_url.zip"
}

variable "redirect_zip_path" {
  description = "Path to the redirect Lambda deployment zip"
  type        = string
  default     = "../bin/create_short_url.zip"
}
