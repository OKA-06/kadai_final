#ECS cluster

resource "aws_ecs_cluster" "kadai_cluster" {
  name = "kadai-cluster"
}

#CloudWatch Logs
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/kadai"
  retention_in_days = 14
}

#IAM Role for ECS Task Execution
data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "kadai-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# ECS Task Definition (dev)
resource "aws_ecs_task_definition" "kadai_task" {
  family                   = "kadai-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "${aws_ecr_repository.nagoyameshi.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/kadai"
          awslogs-region        = "ap-northeast-1"
          awslogs-stream-prefix = "app"
        }
      }
    }
  ])
}


# ECS Task Definition (prod)
resource "aws_ecs_task_definition" "kadai_task_prod" {
  family                   = "kadai-prod-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "app"
      image = "${aws_ecr_repository.nagoyameshi.repository_url}:latest"
      portMappings = [
        { containerPort = 80, hostPort = 80, protocol = "tcp" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = "ap-northeast-1"
          awslogs-stream-prefix = "prod"
        }
      }
    }
  ])
}


#ECS Service(dev)

resource "aws_ecs_service" "dev" {
  name            = "kadai-dev-svc"
  cluster         = aws_ecs_cluster.kadai_cluster.id
  task_definition = aws_ecs_task_definition.kadai_task.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.kadai_private_a.id, aws_subnet.kadai_private_c.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.dev.arn
    container_name   = "app"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.http]

}

resource "aws_appautoscaling_target" "dev" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.kadai_cluster.name}/${aws_ecs_service.dev.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "dev_cpu" {
  name               = "kadai-dev-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dev.resource_id
  scalable_dimension = aws_appautoscaling_target.dev.scalable_dimension
  service_namespace  = aws_appautoscaling_target.dev.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 50
  }
}

#CloudWatch Alarm for ECS dev CPU High
resource "aws_cloudwatch_metric_alarm" "ecs_dev_cpu_high" {
  alarm_name          = "kadai-dev-ecs-cpu-high"
  alarm_description   = "ECS dev service CPU >= 45%"
  namespace           = "AWS/ECS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 2
  threshold           = 45
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.kadai_cluster.name
    ServiceName = aws_ecs_service.dev.name
  }
}

#ECS Service(prod)
resource "aws_ecs_service" "prod" {
  name            = "kadai-prod-svc"
  cluster         = aws_ecs_cluster.kadai_cluster.id
  task_definition = aws_ecs_task_definition.kadai_task_prod.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.kadai_private_a.id, aws_subnet.kadai_private_c.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.prod.arn
    container_name   = "app"
    container_port   = 80
  }
  depends_on = [aws_lb_listener.http]
}


resource "aws_appautoscaling_target" "prod" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.kadai_cluster.name}/${aws_ecs_service.prod.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "prod_cpu" {
  name               = "kadai-prod-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.prod.resource_id
  scalable_dimension = aws_appautoscaling_target.prod.scalable_dimension
  service_namespace  = aws_appautoscaling_target.prod.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 50
  }
}
