# AWS Provider Configuration
provider "aws" {
  region = var.aws_region
}

# EC2 Key Pair Module
module "ec2_key_pair" {
  source = "git::https://github.com/jemalcloud/terrafom-ssh-module.git"
  name   = var.name
  tags = {
    Environment = var.environment
    Project     = var.project
  }
}
# Fetch Public Key from AWS SSM Parameter Store
data "aws_ssm_parameter" "public_key" {
  name = "/ec2/key-pair/${module.ec2_key_pair.key_pair_name}/public-rsa-key-openssh"
  with_decryption = true

  depends_on = [module.ec2_key_pair]
}

# Local Variables for Script Templates
locals {
  script_template = file("${path.module}/scripts/userdata.sh")
}

# Template for userdata.sh
data "template_file" "script" {
  template = local.script_template
  vars = {
    USERNAME = var.name
    AWS_REGION = var.aws_region
    KEY_NAME = module.ec2_key_pair.key_pair_name
    PUBLIC_KEY_CONTENT = data.aws_ssm_parameter.public_key.value
  }

  depends_on = [data.aws_ssm_parameter.public_key]
}

# AWS EC2 Instance
resource "aws_instance" "ec2_instance" {
  ami               = var.ami_id
  instance_type     = var.instance_type
  key_name          = module.ec2_key_pair.key_pair_name
  user_data         = data.template_file.script.rendered

  tags = {
    Name        = var.instance_name
    Environment = var.environment
    Project     = var.project
  }

  depends_on = [module.ec2_key_pair]
}

# Outputs for Debugging
output "script_rendered" {
  value       = data.template_file.script.rendered
  description = "Rendered user data script."
}