# ecs.tf

resource "aws_ecs_cluster" "main" {
  name = "cb-cluster"
}

data "template_file" "cb_app1" {
  template = file("./templates/ecs/cb_app.json.tpl")

  vars = {
    app_image      = var.app_image1
    app_name       = "teacher"
    app_port       = var.app_port
    host_port      = var.app_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
  }
}

data "template_file" "cb_app2" {
  template = file("./templates/ecs/cb_app.json.tpl")

  vars = {
    app_image      = var.app_image2
    app_name       = "student"
    app_port       = var.app_port
    host_port      = var.app_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
  }
}

resource "aws_ecs_task_definition" "app1" {
  family                   = "cb-app-task1"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.cb_app1.rendered
}

resource "aws_ecs_task_definition" "app2" {
  family                   = "cb-app-task2"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.cb_app2.rendered
}

resource "aws_ecs_service" "main1" {
  name            = "cb-service1"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app1.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app1.id
    container_name   = "teacher"
    container_port   = var.app_port
  }

  service_registries {
    registry_arn = aws_service_discovery_service.teacher_dns_discovery_service.arn
  }

  depends_on = [aws_alb_listener.front_end1, aws_lb_listener_rule.teacher, aws_iam_role_policy_attachment.ecs_task_execution_role]
}

resource "aws_ecs_service" "main2" {
  name            = "cb-service2"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app2.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app2.id
    container_name   = "student"
    container_port   = var.app_port
  }

  service_registries {
    registry_arn = aws_service_discovery_service.student_dns_discovery_service.arn
  }

  depends_on = [aws_alb_listener.front_end1, aws_lb_listener_rule.student, aws_iam_role_policy_attachment.ecs_task_execution_role]
}
