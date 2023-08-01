output "db_enpoint" {
  value = aws_db_instance.default.endpoint
}
output "db-password" {
  value = aws_db_instance.default.password
}