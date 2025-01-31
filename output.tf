#  sg id 
output "security_group_id" {
  value = aws_security_group.security_groups.id
}

# LT id

output "launch_template_id" {
  value = aws_launch_template.launch_template.id
}

# TG arn

output "target_group_arn" {
  value = aws_lb_target_group.tg.arn
}


# asg name

output "asg_name" {
  value = aws_autoscaling_group.asg.name
}


output "http_listener_arn" {
  description = "The ARN of the HTTP listener"
  value       = length(aws_lb_listener.http_listener) > 0 ? aws_lb_listener.http_listener[0].arn : null
}