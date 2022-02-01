# outputs.tf

output "alb1_hostname" {
  value = aws_alb.main1.dns_name
}

output "alb2_hostname" {
  value = aws_alb.main2.dns_name
}

output "codedeploy_student_task_arn" {
  value = aws_ecs_task_definition.app2.arn
}

output "codedeploy_teacher_task_arn" {
  value = aws_ecs_task_definition.app1.arn
}
