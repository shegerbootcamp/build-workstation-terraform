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
  count    = fileexists("${path.module}/keystore/${module.ec2_key_pair.key_pair_name}.pem") ? 1 : 0
  filename = "${path.module}/keystore/${module.ec2_key_pair.key_pair_name}.pem"
  depends_on = [null_resource.fetch_public_key]
}

data "template_file" "cloud_init" {
  count = length(data.local_file.public_key) > 0 ? 1 : 0
  template = file("${path.module}/cloud-init.yaml")
  vars = {
    USERNAME           = var.name
    PUBLIC_KEY_CONTENT = length(data.local_file.public_key) > 0 ? data.local_file.public_key[0].content : ""
  }
}

data "template_file" "script" {
  template = file("${path.module}/scripts/userdata.tpl")
}

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
    filename     = "init.tpl"
    content_type = "text/x-shellscript"
    content      = data.template_file.script.rendered
  }
}

resource "aws_instance" "ec2_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = module.ec2_key_pair.key_pair_name
  user_data_base64 = length(data.template_cloudinit_config.config) > 0 ? data.template_cloudinit_config.config[0].rendered : ""

  tags = {
    Name        = var.instance_name
    Environment = var.environment
    Project     = var.project
  }

  depends_on = [null_resource.fetch_public_key]
}

