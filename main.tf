#S3
terraform {
  backend "s3" {
    bucket  = "kadai-final-oka06-state"
    key     = "kadai/terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
  }
}


provider "aws" {
  region = "ap-northeast-1"
}

#CloudFrontとWAF用リージョン
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}


#RDS's variables
variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
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


#RDS

resource "aws_db_subnet_group" "kadai" {
  name       = "kadai-db-subnet-group"
  subnet_ids = [aws_subnet.kadai_private_a.id, aws_subnet.kadai_private_c.id]
}

resource "aws_security_group" "rds_sg" {
  name        = "kadai-rds-sg"
  description = "Allow DB access only from ECS"
  vpc_id      = aws_vpc.kadai_vpc.id

  ingress {
    description     = "MySQL from ECS"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#RDS(dev)
resource "aws_db_instance" "dev" {
  identifier = "kadai-dev-db"

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "kadaidev"
  username = var.db_username
  password = var.db_password

  db_subnet_group_name    = aws_db_subnet_group.kadai.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  publicly_accessible     = false
  multi_az                = true
  apply_immediately       = true
  backup_retention_period = 7
  backup_window           = "18:00-19:00"
  maintenance_window      = "sun:19:00-sun:20:00"

  skip_final_snapshot = true
  deletion_protection = false
}

#RDS(prod)
resource "aws_db_instance" "prod" {
  identifier = "kadai-prod-db"

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "kadaiprod"
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.kadai.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false
  multi_az               = true

  backup_retention_period = 7
  backup_window           = "19:00-20:00"
  maintenance_window      = "sun:20:00-sun:21:00"

  skip_final_snapshot       = true #<- 要確認
  final_snapshot_identifier = "kadai-prod-final-snapshot"
  #↑chatGPT addition、削除の時にいるらしい
  deletion_protection = false
}
