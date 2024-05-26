output "key_pair_name" {
  value       = module.ec2_key_pair.key_pair_name
  description = "Key pair name."
}

output "tls_private_ssm" {
  value       = module.ec2_key_pair.tls_private_ssm
  description = "Private key."
  sensitive   = true
}

output "tls_public_rsa_ssm" {
  value       = module.ec2_key_pair.tls_public_rsa_ssm
  description = "Private key RSA."
  sensitive   = true
}

output "tls_public_ssm" {
  value       = module.ec2_key_pair.tls_public_ssm
  description = "Public key."
}