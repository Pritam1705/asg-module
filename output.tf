#  sg id 
output "security_group_id" {
  value = module.asg.security_group_id
}

# LT id

output "launch_template_id" {
  value = module.asg.launch_template_id
}

# TG arn

output "target_group_arn" {
  value = module.asg.target_group_arn
}


# asg name

output "asg_name" {
  value = module.asg.asg_name
}

output "http_listener_arn" {
  description = "The ARN of the HTTP listener"
  value       = module.asg.http_listener_arn
}