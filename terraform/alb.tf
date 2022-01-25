# alb.tf

resource "aws_alb" "main1" {
  name            = "cb-load-balancer1"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]
}

resource "aws_alb" "main2" {
  name            = "cb-load-balancer2"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]
}

resource "aws_alb_target_group" "app1" {
  name        = "cb-target-group1"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "10"
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end1" {
  load_balancer_arn = aws_alb.main1.id
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.app1.id
    type             = "forward"
  }
}

resource "aws_alb_target_group" "app2" {
  name        = "cb-target-group2"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "10"
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end2" {
  load_balancer_arn = aws_alb.main2.id
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.app2.id
    type             = "forward"
  }
}
