output "sg-web-id" {
  value = aws_security_group.web.id 
}

output "sg-db-id" {
  value = aws_security_group.db.id 
}