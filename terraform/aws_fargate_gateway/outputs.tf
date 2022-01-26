# outputs.tf

output "alb1_hostname" {
  value = aws_alb.main1.dns_name
}
