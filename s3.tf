terraform {
  backend "s3" {
    bucket         = "ssh-aws-parameter-store"  # Set your S3 bucket name
    key            = "terraform.tfstate" # Set the name of the state file
    region         = "us-east-1"       # Set your AWS region
    encrypt        = true                # (Optional) Encrypt the state file
    dynamodb_table = "terraform_locks"    # (Optional) DynamoDB table for state locking
  }
}