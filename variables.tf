variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources."
  default     = "us-east-1"  # or your preferred region
}

variable "key_pair_name" {
  type        = string
  description = "Key pair name."
  default     = "my-key-pair"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for the EC2 instance."
}

variable "instance_type" {
  type        = string
  description = "Instance type for the EC2 instance."
  default     = "t2.micro"
}

variable "instance_name" {
  type        = string
  description = "Name tag for the EC2 instance."
}

variable "environment" {
  type        = string
  description = "Environment for the deployment."
  default     = "dev"
}

variable "project" {
  type        = string
  description = "Project name for tagging."
  default     = "example"
}

variable "name" {
  type        = string
  description = "The name of the user to create for SSH access."
  default     = "ec2-user"
}
