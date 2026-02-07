output "jarvis_vpc_id" {
  value = aws_vpc.jarvis_vpc01.id
}

output "jarvis_public_subnet_ids" {
  value = aws_subnet.jarvis_public_subnets[*].id
}

output "jarvis_private_subnet_ids" {
  value = aws_subnet.jarvis_private_subnets[*].id
}

output "super_lab_ec2_public_ip" {
  value = aws_instance.jarvis_ec2_01.public_ip
}

output "super_lab_ec2_public_dns" {
  value = aws_instance.jarvis_ec2_01.public_dns
}

output "super_lab_rds_endpoint" {
  value = aws_db_instance.jarvis_rds01.address
}

output "super_lab_secret_name" {
  value = aws_secretsmanager_secret.jarvis_db_secret01.name
}

output "super_lab_secret_arn" {
  value = aws_secretsmanager_secret.jarvis_db_secret01.arn
}