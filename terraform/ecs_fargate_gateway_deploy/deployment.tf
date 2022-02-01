resource "aws_codedeploy_app" "student_codedeploy_app" {
  compute_platform = "ECS"
  name             = "student-codedeploy-app"
}

resource "aws_codedeploy_app" "teacher_codedeploy_app" {
  compute_platform = "ECS"
  name             = "teacher-codedeploy-app"
}

resource "aws_codedeploy_deployment_config" "student_codedeploy_config" {
  deployment_config_name = "student-codedeploy-config"
  compute_platform       = "ECS"

  traffic_routing_config {
    type = "TimeBasedCanary"

    time_based_canary {
      interval   = 5
      percentage = 10
    }
  }
}

resource "aws_codedeploy_deployment_group" "student_codedeploy_group" {
  app_name               = aws_codedeploy_app.student_codedeploy_app.name
  deployment_config_name = aws_codedeploy_deployment_config.student_codedeploy_config.deployment_config_name
  deployment_group_name  = "student-codedeploy-group"
  service_role_arn       = aws_iam_role.codedeploy.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.main.name
    service_name = aws_ecs_service.main2.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_alb_listener.front_end2.arn]
      }

      target_group {
        name = aws_alb_target_group.student_blue.name
      }

      target_group {
        name = aws_alb_target_group.student_green.name
      }
    }
  }
}

resource "aws_codedeploy_deployment_group" "teacher_codedeploy_group" {
  app_name               = aws_codedeploy_app.teacher_codedeploy_app.name
  deployment_config_name = aws_codedeploy_deployment_config.student_codedeploy_config.deployment_config_name
  deployment_group_name  = "teacher-codedeploy-group"
  service_role_arn       = aws_iam_role.codedeploy.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.main.name
    service_name = aws_ecs_service.main1.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_alb_listener.front_end1.arn]
      }

      target_group {
        name = aws_alb_target_group.teacher_blue.name
      }

      target_group {
        name = aws_alb_target_group.teacher_green.name
      }
    }
  }
}

data "aws_iam_policy_document" "assume_by_codedeploy" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codedeploy" {
  name               = "codedeploy"
  assume_role_policy = data.aws_iam_policy_document.assume_by_codedeploy.json
}

data "aws_iam_policy_document" "codedeploy" {
  statement {
    sid    = "AllowLoadBalancingAndECSModifications"
    effect = "Allow"

    actions = [
      "ecs:CreateTaskSet",
      "ecs:DeleteTaskSet",
      "ecs:DescribeServices",
      "ecs:UpdateServicePrimaryTaskSet",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyRule",
      "s3:GetObject"
    ]

    resources = ["*"]
  }
  statement {
    sid    = "AllowPassRole"
    effect = "Allow"

    actions = ["iam:PassRole"]

    resources = [
      aws_iam_role.ecs_task_execution_role.arn
    ]
  }
}
resource "aws_iam_role_policy" "codedeploy" {
  role   = aws_iam_role.codedeploy.name
  policy = data.aws_iam_policy_document.codedeploy.json
}
