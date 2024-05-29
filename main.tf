provider "aws" {
  region = var.aws_region
}

module "ec2_key_pair" {
  source = "git::https://github.com/jemalcloud/terrafom-ssh-module.git"
  name   = var.name
  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

resource "null_resource" "fetch_public_key" {
  provisioner "local-exec" {
    command = <<-EOT
      mkdir -p keystore
      aws ssm get-parameter --name "/ec2/key-pair/${module.ec2_key_pair.key_pair_name}/public-rsa-key-openssh" --region "${var.aws_region}" --with-decryption --query "Parameter.Value" --output text > keystore/${module.ec2_key_pair.key_pair_name}.pem
    EOT
  }

  depends_on = [module.ec2_key_pair]
}

data "local_file" "public_key" {
  filename  = "${path.module}/keystore/${module.ec2_key_pair.key_pair_name}.pem"
  depends_on = [null_resource.fetch_public_key]
}

data "template_file" "cloud_init" {
  template = file("${path.module}/cloud-init.yaml")
  vars = {
    USERNAME           = var.name
    PUBLIC_KEY_CONTENT = data.local_file.public_key.content
  }
}

data "local_file" "userdata_script" {
  filename = "${path.module}/scripts/userdata.sh"
}

data "template_file" "combined_user_data" {
  template = <<-EOF
${data.template_file.cloud_init.rendered}

# Bash script starts here
${data.local_file.userdata_script.content}
EOF
}

resource "aws_instance" "ec2_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = module.ec2_key_pair.key_pair_name
  user_data     = data.template_file.combined_user_data.rendered

  tags = {
    Name        = var.instance_name
    Environment = var.environment
    Project     = var.project
  }

  depends_on = [null_resource.fetch_public_key]
}
