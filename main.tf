# Configure the AWS provider with the specified region
provider "aws" {
  region = var.aws_region
}

# Module to create an EC2 key pair
module "ec2_key_pair" {
  source = "git::https://github.com/jemalcloud/terrafom-ssh-module.git"
  name   = var.name
  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# Resource to fetch the public key from AWS SSM and store it locally
resource "null_resource" "fetch_public_key" {
  provisioner "local-exec" {
    command = <<-EOT
      mkdir -p keystore
      aws ssm get-parameter --name "/ec2/key-pair/${module.ec2_key_pair.key_pair_name}/public-rsa-key-openssh" --region "${var.aws_region}" --with-decryption --query "Parameter.Value" --output text > keystore/${module.ec2_key_pair.key_pair_name}.pem
    EOT
  }
  depends_on = [module.ec2_key_pair]
}

# Data source to read the public key file
data "local_file" "public_key" {
  count    = fileexists("${path.module}/keystore/${module.ec2_key_pair.key_pair_name}.pem") ? 1 : 0
  filename = "${path.module}/keystore/${module.ec2_key_pair.key_pair_name}.pem"
  depends_on = [null_resource.fetch_public_key]
}

# Local variables to store the content of the cloud-init and userdata scripts
locals {
  cloud_init_template = file("${path.module}/cloud-init.yaml")
  script_template     = file("${path.module}/scripts/userdata.sh")
}

# Template file data source for cloud-init.yaml
data "template_file" "cloud_init" {
  count = length(data.local_file.public_key) > 0 ? 1 : 0
  template = local.cloud_init_template
  vars = {
    USERNAME           = var.name
    PUBLIC_KEY_CONTENT = length(data.local_file.public_key) > 0 ? data.local_file.public_key[0].content : ""
  }
}

# Template file data source for userdata.sh
data "template_file" "script" {
  template = local.script_template
}

# Combine cloud-init.yaml and userdata.sh into a single cloud-init configuration
data "template_cloudinit_config" "config" {
  count         = length(data.template_file.cloud_init) > 0 ? 1 : 0
  gzip          = true
  base64_encode = true

  part {
    filename     = "cloud-init.yaml"
    content_type = "text/cloud-config"
    content      = data.template_file.cloud_init[count.index].rendered
  }

  part {
    filename     = "userdata.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.script.rendered
  }
}

# AWS EC2 instance resource
resource "aws_instance" "ec2_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = module.ec2_key_pair.key_pair_name
  user_data_base64 = length(data.template_file.cloud_init) > 0 ? data.template_cloudinit_config.config[0].rendered : ""

  tags = {
    Name        = var.instance_name
    Environment = var.environment
    Project     = var.project
  }

  depends_on = [null_resource.fetch_public_key]
}

# Outputs for debugging and verification
output "cloud_init_template" {
  value       = file("${path.module}/cloud-init.yaml")
  description = "Raw content of the cloud-init.yaml template file."
}

output "cloud_init_rendered" {
  value       = length(data.template_file.cloud_init) > 0 ? data.template_file.cloud_init[0].rendered : "No rendered content"
  description = "Rendered cloud-init content."
}

output "script_rendered" {
  value       = data.template_file.script.rendered
  description = "Rendered user data script."
}

output "user_data_base64" {
  value       = length(data.template_file.cloud_init) > 0 ? data.template_cloudinit_config.config[0].rendered : "No user data"
  description = "Base64 encoded user data."
}

output "rendered_cloud_init_config" {
  value       = length(data.template_cloudinit_config.config) > 0 ? data.template_cloudinit_config.config[0].rendered : "No rendered content"
  description = "Rendered cloud-init configuration."
}