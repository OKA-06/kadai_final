provider "aws" {
  region = "ap-northeast-1"
}


#vpc

resource "aws_vpc" "kadai_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "kadai_igw" {
  vpc_id = aws_vpc.kadai_vpc.id
}

#subnet

resource "aws_subnet" "kadai_public_a" {
  vpc_id                  = aws_vpc.kadai_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "kadai_public_c" {
  vpc_id                  = aws_vpc.kadai_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true
}
resource "aws_subnet" "kadai_private_a" {
  vpc_id                  = aws_vpc.kadai_vpc.id
  cidr_block              = "10.0.11.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false
}
resource "aws_subnet" "kadai_private_c" {
  vpc_id                  = aws_vpc.kadai_vpc.id
  cidr_block              = "10.0.12.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false
}

#route table
resource "aws_route_table" "kadai_public_rt" {
  vpc_id = aws_vpc.kadai_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kadai_igw.id
  }
}
resource "aws_route_table_association" "kadai_public_a_rta" {
  subnet_id      = aws_subnet.kadai_public_a.id
  route_table_id = aws_route_table.kadai_public_rt.id
}

resource "aws_route_table_association" "kadai_public_c_rta" {
  subnet_id      = aws_subnet.kadai_public_c.id
  route_table_id = aws_route_table.kadai_public_rt.id
}

resource "aws_route_table" "kadai_private_rt" {
  vpc_id = aws_vpc.kadai_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.kadai_nat_gw_a.id
  }
}

resource "aws_route_table_association" "kadai_private_a_rta" {
  subnet_id      = aws_subnet.kadai_private_a.id
  route_table_id = aws_route_table.kadai_private_rt.id
}

resource "aws_route_table_association" "kadai_private_c_rta" {
  subnet_id      = aws_subnet.kadai_private_c.id
  route_table_id = aws_route_table.kadai_private_rt.id
}


#nat gateway

resource "aws_eip" "kadai_nat_eip_a" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.kadai_igw]
}
resource "aws_nat_gateway" "kadai_nat_gw_a" {
  allocation_id = aws_eip.kadai_nat_eip_a.id
  subnet_id     = aws_subnet.kadai_public_a.id
  depends_on    = [aws_internet_gateway.kadai_igw]
}


#security group

resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.kadai_vpc.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "ecs_sg"
  description = "Allow traffic from ALB"
  vpc_id      = aws_vpc.kadai_vpc.id

  ingress {
    description = "HTTP from ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.kadai_vpc.cidr_block]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

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
      type        = "services"
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

resource "aws_ecs_task_definition" "kadai_task" {
  family                   = "kadai-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "app"
      image = "nginx:latest"
      portMappings = [
        { containerPort = 80, hostPort = 80, protocol = "tcp" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = "ap-northeast-1"
          awslogs-stream-prefix = "app"
        }
      }
    }
  ])
}

#ECS Service
resource "aws_ecs_service" "dev" {
  name            = "kadai-dev-svc"
  cluster         = aws_ecs_cluster.kadai_cluster.id
  task_definition = aws_ecs_task_definition.kadai_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.kadai_private_a.id, aws_subnet.kadai_private_c.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }
}

resource "aws_appautoscaling_target" "dev" {
  max_capacity       = 4
  min_capacity       = 1
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
