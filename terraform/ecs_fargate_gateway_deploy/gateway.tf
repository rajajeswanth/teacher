data "aws_subnet_ids" "private" {
  vpc_id = aws_vpc.main.id

  filter {
    name   = "tag:Tier"
    values = ["Private"]
  }

  depends_on = [aws_subnet.private]
}

resource "aws_apigatewayv2_vpc_link" "private_vpc_link" {
  name               = "private-vpc-link"
  subnet_ids         = data.aws_subnet_ids.private.ids
  security_group_ids = [aws_security_group.lb.id]
}

resource "aws_apigatewayv2_api" "my_api" {
  name          = "my-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "my_api_integration" {
  api_id           = aws_apigatewayv2_api.my_api.id
  description      = "Gateway API with a load balancer"
  integration_type = "HTTP_PROXY"
  integration_uri  = aws_alb_listener.front_end1.arn

  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.private_vpc_link.id
}

resource "aws_apigatewayv2_route" "student_route" {
  api_id    = aws_apigatewayv2_api.my_api.id
  route_key = "$default"

  target = "integrations/${aws_apigatewayv2_integration.my_api_integration.id}"
}

resource "aws_apigatewayv2_deployment" "student_route_deployment" {
  api_id      = aws_apigatewayv2_route.student_route.api_id
  description = "Student Route deployment"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_stage" "student" {
  api_id        = aws_apigatewayv2_api.my_api.id
  name          = "$default"
  deployment_id = aws_apigatewayv2_deployment.student_route_deployment.id
  route_settings {
    route_key              = aws_apigatewayv2_route.student_route.route_key
    throttling_rate_limit  = 10
    throttling_burst_limit = 1000
  }
}
