resource "aws_ecs_cluster" "web-cluster" {
  name               = var.cluster_name
  capacity_providers = [aws_ecs_capacity_provider.test.name]
  tags = {
    "env"       = "dev"
    "createdBy" = "pgandla"
  }
}

resource "aws_ecs_capacity_provider" "test" {
  name = "capacity-provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_asg.arn
    managed_termination_protection = "ENABLED"
    managed_scaling {
      status          = "ENABLED"
      target_capacity = 85
    }
  }
}

resource "aws_ecs_task_definition" "ecs-task-def" {
  container_definitions = file("container-def.json")
  family                = "web-family"
  network_mode          = "bridge"
  tags = {
    "env"       = "dev"
    "createdBy" = "pgandla"
  }
}

resource "aws_ecs_service" "ecs-service" {
  name            = "web-service"
  cluster         = aws_ecs_cluster.web-cluster.id
  task_definition = aws_ecs_task_definition.ecs-task-def.arn
  desired_count   = 10
  iam_role = aws_iam_service_linked_role.service-role.arn
  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
  load_balancer {
    container_name   = "color-flower"
    container_port   = 80
    target_group_arn = aws_lb_target_group.lb-target-grp.arn
  }
  lifecycle {
    ignore_changes = [desired_count]
  }
  launch_type = "EC2"
  depends_on  = [aws_lb_listener.web-listener, aws_iam_service_linked_role.service-role]
}

resource "aws_cloudwatch_log_group" "log-grp" {
  name = "/ecs/frontend-container"
  tags = {
    "env"       = "dev"
    "createdBy" = "pgandla"
  }
}