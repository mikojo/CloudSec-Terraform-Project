output "rds_endpoint" {
  value = aws_db_instance.capstone-rds.endpoint
}

output "elb_dns" {
  value = aws_lb.capstone-elb.dns_name
}
