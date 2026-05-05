variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "project_name" {
  type    = string
  default = "api-consumer-frontend"
}

variable "domain_name" {
  description = "Custom domain for CloudFront (leave empty to use the default .cloudfront.net domain)"
  type        = string
  default     = ""
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN in us-east-1 (required when domain_name is set)"
  type        = string
  default     = ""
}
