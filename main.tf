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

# Fetch Public Key
resource "null_resource" "fetch_public_key" {
  provisioner "local-exec" {
    command = <<-EOT
      mkdir -p keystore
      aws ssm get-parameter --name "/ec2/key-pair/${module.ec2_key_pair.key_pair_name}/public-rsa-key-openssh" --region "${var.aws_region}" --with-decryption --query "Parameter.Value" --output text > keystore/${module.ec2_key_pair.key_pair_name}.pem
    EOT
  }
  depends_on = [module.ec2_key_pair]
}

# Read Public Key File
data "local_file" "public_key" {
  count    = fileexists("${path.module}/keystore/${module.ec2_key_pair.key_pair_name}.pem") ? 1 : 0
  filename = "${path.module}/keystore/${module.ec2_key_pair.key_pair_name}.pem"
  depends_on = [null_resource.fetch_public_key]
}

# Local Variables for Script Templates
locals {
  script_template = file("${path.module}/scripts/userdata.sh")
}

# Template for userdata.sh
data "template_file" "script" {
  template = local.script_template
  vars = {
    USERNAME           = var.name
    PUBLIC_KEY_CONTENT = length(data.local_file.public_key) > 0 ? data.local_file.public_key[0].content : ""
  }
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

  depends_on = [null_resource.fetch_public_key]
}

# Outputs for Debugging
output "script_rendered" {
  value       = data.template_file.script.rendered
  description = "Rendered user data script."
}