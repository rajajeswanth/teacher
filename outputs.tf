# outputs.tf

output "alb1_hostname" {
  value = aws_alb.main1.dns_name
}

output "alb2_hostname" {
  value = aws_alb.main2.dns_name
}
