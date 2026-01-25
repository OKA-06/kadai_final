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
  username = data.aws_ssm_parameter.dev_db_username.value
  password = data.aws_ssm_parameter.dev_db_password.value

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
  username = data.aws_ssm_parameter.prod_db_username.value
  password = data.aws_ssm_parameter.prod_db_password.value

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
