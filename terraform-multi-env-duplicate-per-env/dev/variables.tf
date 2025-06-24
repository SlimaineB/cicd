variable "region" {
  default     = "us-east-2"
  description = "AWS region"
}

variable "environment" {
  default     = "dev"
  description = "The name of the Environment"
}

variable "bucket_name" {
  default     = "my-unique-bucket-name"
  description = "The name of the S3 bucket"
}
