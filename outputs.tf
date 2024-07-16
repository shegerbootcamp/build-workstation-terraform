output "key_pair_name" {
  value       = module.ec2_key_pair.key_pair_name
  description = "The name of the EC2 key pair."
}

output "tls_private_ssm" {
  value       = module.ec2_key_pair.tls_private_ssm
  description = "The private key retrieved from SSM."
  sensitive   = true
}

output "tls_public_ssm" {
  value       = module.ec2_key_pair.tls_public_ssm
  description = "The public key retrieved from SSM."
  sensitive   = true
}

//output "userdata" {
  //value       = length(data.template_file.cloud_init) > 0 ? data.template_cloudinit_config.config[0].rendered : ""
  //description = "The user data for the EC2 instance in base64 encoded format."
//}

output "ec2_configure" {
  value       = data.template_file.script.rendered
  description = "The rendered user data script."
}
