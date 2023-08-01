
data "aws_ami" "amazon-linux2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

}
resource "tls_private_key" "example" {

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "test_terraform"
  public_key = tls_private_key.example.public_key_openssh
  provisioner "local-exec" { # Create a "myKey.pem" to your computer!!
    command = "echo '${tls_private_key.example.private_key_pem}' >> test_terraform.pem"
  }
}

data "aws_ami" "windows_app" {
     most_recent = true     
filter {
       name   = "name"
       values = ["Windows_Server-2019-English-Full-Base-*"]  
  }     
filter {
       name   = "virtualization-type"
       values = ["hvm"]  
  }     
owners = ["amazon"] # Canonical
}
data "aws_ami" "windows_database" {
     most_recent = true     
filter {
       name   = "name"
       values = ["Windows_Server-2019-English-Full-SQL_2019_Standard-*"]  
  }     
filter {
       name   = "virtualization-type"
       values = ["hvm"]  
  }     
owners = ["801119661308"] # Canonical
}
resource "aws_instance" "instance_public" {
  count                  = length(var.subnet_public)
  ami                    = data.aws_ami.amazon-linux2.id
  instance_type          = "t2.medium"
  subnet_id              = var.subnet_public[count.index]
  vpc_security_group_ids = [var.sg_public]
  ebs_block_device {
    volume_size = 20
    device_name = "/dev/xvda"
    volume_type = "gp3"
  }
  #user_data              = file("EC2/install_httpd.sh")
  key_name      = aws_key_pair.generated_key.key_name
  tags = {
    Name = format("vpc_test_EC2_Public_%s", var.az[count.index])
  }
}
# resource "aws_instance" "instance_private" {
#   count                  = length(var.subnet_private)
#   ami                    = data.aws_ami.windows_database.id
#   #key_name               = "linux"
#   instance_type          = "c6i.4xlarge"
#   subnet_id              = var.subnet_private[count.index]
#   vpc_security_group_ids = [var.sg_private]
#   ebs_block_device {
#     volume_size = 350
#     device_name = "/dev/xvda"
#     volume_type = "gp3"
#   }
#   #user_data              = file("EC2/install_httpd.sh")
#   key_name      = aws_key_pair.generated_key.key_name
#   tags = {
#     Name = format("vpc_test_EC2_Private_%s", var.az[count.index])
#   }
# }
