#########################################
# security group
###############################################

resource "aws_security_group" "security_groups" {
  vpc_id      = data.terraform_remote_state.network_skeleton_state.outputs.vpc_id
  
  ingress  {
    from_port   = var.application_port
    to_port     = var.application_port
    protocol    = var.tcp_protocol
    security_groups = [data.terraform_remote_state.network_skeleton_state.outputs.load_balancer_sg_id]
    description      = "Allow traffic from ALB SG"
  }

  egress  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.sg_name
    Environment = var.environment
  }
}


################################################
# Launch Template Configuration
#############################################

resource "aws_launch_template" "launch_template" {
  name = var.launch_template_name
  image_id      = var.ami_id 
  instance_type = var.instance_type             
  key_name      = var.key_name
  
  network_interfaces {
    subnet_id                   = data.terraform_remote_state.network_skeleton_state.outputs.application_subnet_id
    security_groups             = [aws_security_group.security_groups.id]
    
  }

}


#######################################################
# Target group
#######################################################

# target group

resource "aws_lb_target_group" "tg" {
  name      = var.tg_name
  port     = var.application_port
  protocol = var.http_protocol
  vpc_id   = data.terraform_remote_state.network_skeleton_state.outputs.vpc_id
   health_check {
    interval            = var.interval
    path                = var.health_check_path
    protocol            = var.http_protocol
    timeout             = var.timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }

}



###############################################
# Default Listener
###############################################

resource "aws_lb_listener" "http_listener" {
  count             = var.enable_http_listener ? 1 : 0
  load_balancer_arn = data.terraform_remote_state.network_skeleton_state.outputs.alb_arn
  port              = var.http_listener_port
  protocol          = var.http_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

#######################################################
# Auto Scaling Group
########################################################

resource "aws_autoscaling_group" "asg" {
  name                = var.asg_name
  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }
  min_size           = var.min_size
  max_size           = var.max_size
  desired_capacity   = var.desired_capacity

  vpc_zone_identifier = [data.terraform_remote_state.network_skeleton_state.outputs.application_subnet_id] 
  target_group_arns = [aws_lb_target_group.tg.arn]

   tag {
    key                 = "Name"
    value               = var.instance_name
    propagate_at_launch = true
  }

}

####################################
#  ASG policy
#########################################


resource "aws_autoscaling_policy" "autoscaling_policy" {
  name                   = var.policy_name
  policy_type            = var.policy_type
  adjustment_type        = var.adjustment_type
  estimated_instance_warmup = var.estimated_instance_warmup
  autoscaling_group_name = aws_autoscaling_group.asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.metric_type
    }
    target_value = var.target_value
  }
}