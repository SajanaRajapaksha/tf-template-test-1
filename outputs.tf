output "bucket_name" {

  description = "Name of the insecure S3 bucket used for Checkov testing"

  value = aws_s3_bucket.insecure_bucket.bucket

}

output "security_group_name" {

  description = "Name of the public SSH security group used for Checkov testing"

  value = aws_security_group.public_ssh.name

}

output "hardcoded_password_exposed" {
  value       = aws_ssm_parameter.hardcoded_password.value
  description = "Intentionally exposed password output for testing"
  sensitive   = false
}