resource "aws_db_subnet_group" "private" {
  name       = "private"
  subnet_ids = [var.subnet[0]]
}
data "aws_kms_key" "db" {
  key_id = "arn:aws:kms:ap-northeast-1:723865550634:key/c73f2c1c-d2f8-4500-b7b7-72d2c8a1e621"
}

resource "aws_db_instance" "default" {
  allocated_storage           = 10
  multi_az                    = false
  vpc_security_group_ids      = [var.security_group]
  db_name                     = "mydb"
  engine                      = "mysql"
  engine_version              = "8.0"
  instance_class              = "db.t2.micro"
  username                    = "admin"
  
  password             = aws_secretsmanager_secret.db.id
 #manage_master_user_password = true
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.private.name
}



