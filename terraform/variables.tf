variable "aws_region" {
  description = "AWS region for the S3 bucket (CloudFront is global; ACM certs for CF must be in us-east-1)."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short project identifier used to name resources."
  type        = string
  default     = "my-react-app"
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default = {
    Project   = "my-react-app"
    ManagedBy = "terraform"
  }
}
