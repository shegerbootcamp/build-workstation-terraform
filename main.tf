provider "aws" {
  region = var.aws_region
}

module "ec2_key_pair" {
  //source = "../terraform-ssh-module" # Update this path to where your module is located
  source = "git::https://github.com/jemalcloud/terrafom-ssh-module.git"
  //"git::ssh://username@example.com/storage.git"
  name = var.name
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



resource "aws_instance" "ec2_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = module.ec2_key_pair.key_pair_name
  #key_name = "cloudsheger"
  user_data = data.template_file.user_data.rendered

  tags = {
    Name        = var.instance_name
    Environment = var.environment
    Project     = var.project
  }
}
