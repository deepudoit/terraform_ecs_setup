data "aws_ami" "amzn_linux" {
  owners = ["amazon", "self"]

  filter {
    name   = "name"
    values = ["amzn-ami*amazon-ecs-optimized"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  most_recent = true
}

resource "aws_security_group" "ec2-sg" {
  name        = "allow-all-ec2"
  description = "allow all"
  vpc_id      = data.aws_vpc.main.id
  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pgandla"
  }
}

resource "aws_launch_configuration" "ec2-lc" {
  name          = "test_ecs"
  image_id      = data.aws_ami.amzn_linux.id
  instance_type = "t2.micro"
  lifecycle {
    create_before_destroy = true
  }
  iam_instance_profile        = aws_iam_service_linked_role.service-role.arn
  key_name                    = var.key_name
  security_groups             = [aws_security_group.ec2-sg.id]
  associate_public_ip_address = true
  user_data                   = <<EOT
  #!/bin/bash
  sudo apt-get update
  sudo echo "ECS_CLUSTER=${var.cluster_name}" >> /etc/ecs/ecs.config
  EOT
}

resource "aws_autoscaling_group" "ecs_asg" {
  name                      = "test-asg"
  launch_configuration      = aws_launch_configuration.ec2-lc.name
  max_size                  = 4
  min_size                  = 3
  desired_capacity          = 3
  health_check_type         = "ELB"
  health_check_grace_period = 300
  vpc_zone_identifier       = module.vpc.public_subnets
  target_group_arns         = [aws_lb_target_group.lb-target-grp.arn]
  protect_from_scale_in     = true
  lifecycle {
    create_before_destroy = true
  }
}
