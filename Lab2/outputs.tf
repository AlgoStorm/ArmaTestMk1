# Explanation: Outputs are your mission report—what got built and where to find it.
output "jarvis_vpc_id" {
  value = aws_vpc.jarvis_vpc01.id
}

output "jarvis_public_subnet_ids" {
  value = aws_subnet.jarvis_public_subnets[*].id
}

output "jarvis_private_subnet_ids" {
  value = aws_subnet.jarvis_private_subnets[*].id
}

#output "jarvis_ec2_public_instance_id" {
#   value = aws_instance.jarvis_ec2_public01.id
#}

#output "jarvis_ec2_private_instance_id" {
# value = aws_instance.jarvis_ec2_private01.id
#}

output "jarvis_rds_endpoint" {
  value = aws_db_instance.jarvis_rds01.address
}

output "jarvis_sns_topic_arn" {
  value = aws_sns_topic.jarvis_sns_topic01.arn
}

output "jarvis_log_group_name" {
  value = "/aws/ec2/${var.project_name}-rds-app" # Log group managed outside of Terraform
}