output "dns" {
  description = "DNS at which the machine is reachable"
  value = aws_route53_record.www.fqdn
}