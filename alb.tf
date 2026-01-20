#
# ALB
#
resource "aws_lb" "kadai_alb" {
  name               = "kadai-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [
    aws_subnet.kadai_public_a.id,
    aws_subnet.kadai_public_c.id
    ]

  enable_deletion_protection = false
}

# ALB Target Groups

resource "aws_lb_target_group" "dev" {
  name        = "kadai-tg-dev"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.kadai_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "prod" {
  name        = "kadai-tg-prod"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.kadai_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# ALB Listeners

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.kadai_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev.arn
  }
}

#以下chatGPT追加分
# ALB Listener Rules

resource "aws_lb_listener_rule" "prod_host" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  condition {
    host_header {
      values = ["example.com"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod.arn
  }
}

resource "aws_lb_listener_rule" "dev_host" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  condition {
    host_header {
      values = ["dev.example.com"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev.arn
  }
}
#ECSの方にアタッチメント文が必要？
# ALB Target Group Attachments
