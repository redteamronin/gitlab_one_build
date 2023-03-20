variable "route53_zone" {
  type        = string
  description = "Zone ID for the domain"
  default     = "..."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to house the security group"
  default     = "vpc-..."
}

variable "ip[_cidrs" {
  type        = string
  description = "IP Addresses"
  default     = "0.0.0.0/0"
}

variable "ami_id" {
  type        = string
  description = "Debian 11"
  default     = "ami-..."
}

variable "subnet_id" {
  type        = string
  description = "Public Subnet ID"
  default     = "subnet-..."
}

variable "instance_type" {
  type        = string
  description = "EC2 instance sizing, minimum t2.medium for Gitlab"
  default     = "t2.medium"
}

variable "region" {
  type        = string
  description = "Region to deploy resources"
  default     = "us-east-2"
}

variable "domain" {
  type        = string
  description = "Domain to associate the gitlab instance with"
  default     = "example.com"
}

variable "key_name" {
  type = string
  description = "Key to use during Terraform build"
  default = ""
}

variable "users_list" {
  type = map(any)
  default = {
    "user" = "..."
  }
}