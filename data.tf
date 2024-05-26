data "template_file" "user_data" {
  template = file("${path.module}/scripts/userdata.sh")
  vars = {
    USERNAME        = var.name
    PUBLIC_KEY_PATH = "keystore/${module.ec2_key_pair.key_pair_name}.pem"
  }
}