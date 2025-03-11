
# data "aws_ami" "amazon-linux2" {
#   most_recent = true
#   owners      = ["amazon"]
#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm*"]
#   }

# }
resource "tls_private_key" "example" {

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "test_localstack"
  public_key = tls_private_key.example.public_key_openssh
  provisioner "local-exec" { # Create a "myKey.pem" to your computer!!
    command = "echo '${tls_private_key.example.private_key_pem}' >> test_localstack.pem"
  }
}

# data "aws_ami" "windows_app" {
#      most_recent = true     
# filter {
#        name   = "name"
#        values = ["Windows_Server-2019-English-Full-Base-*"]  
#   }     
# filter {
#        name   = "virtualization-type"
#        values = ["hvm"]  
#   }     
# owners = ["amazon"] # Canonical
# }
# data "aws_ami" "windows_database" {
#      most_recent = true     
# filter {
#        name   = "name"
#        values = ["Windows_Server-2019-English-Full-SQL_2019_Standard-*"]  
#   }     
# filter {
#        name   = "virtualization-type"
#        values = ["hvm"]  
#   }     
# owners = ["801119661308"] # Canonical
# }
# resource "aws_instance" "instance_public" {
#   count                  = length(var.subnet_public)
#   ami                    = data.aws_ami.amazon-linux2.id
#   instance_type          = "t2.medium"
#   subnet_id              = var.subnet_public[count.index]
#   vpc_security_group_ids = [var.sg_public]
#   ebs_block_device {
#     volume_size = 20
#     device_name = "/dev/xvda"
#     volume_type = "gp3"
#   }
#   #user_data              = file("EC2/install_httpd.sh")
#   key_name      = aws_key_pair.generated_key.key_name
#   tags = {
#     Name = format("vpc_test_EC2_Public_%s", var.az[count.index])
#   }
# }
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

resource "aws_launch_template" "ecs_lt" {
 name_prefix   = "ecs-template"
 image_id      = "ami-0801a63f0471e5ad8"
 instance_type = "t3.micro"

 key_name               = aws_key_pair.generated_key.key_name
 vpc_security_group_ids = [var.vpc_security_group_ids]
 iam_instance_profile {
   name = "ecsInstanceRole"
 }

 block_device_mappings {
   device_name = "/dev/xvda"
   ebs {
     volume_size = 30
     volume_type = "gp2"
   }
 }

 tag_specifications {
   resource_type = "instance"
   tags = {
     Name = "ecs-instance"
   }
 }

 user_data = filebase64("${path.module}/ecs.sh")
}
resource "aws_autoscaling_group" "ecs_asg" {
 vpc_zone_identifier = [for subnet in var.subnet_public : subnet]
 desired_capacity    = 2
 max_size            = 3
 min_size            = 1

 launch_template {
   id      = aws_launch_template.ecs_lt.id
   version = "$Latest"
 }

 tag {
   key                 = "AmazonECSManaged"
   value               = true
   propagate_at_launch = true
 }
}
resource "aws_lb" "ecs_alb" {
 name               = "ecs-alb"
 internal           = false
 load_balancer_type = "application"
 security_groups    = [var.vpc_security_group_ids]
 subnets            = [for subnet in var.subnet_public : subnet]

 tags = {
   Name = "ecs-alb"
 }
}

resource "aws_lb_listener" "ecs_alb_listener" {
 load_balancer_arn = aws_lb.ecs_alb.arn
 port              = 80
 protocol          = "HTTP"

 default_action {
   type             = "forward"
   target_group_arn = aws_lb_target_group.ecs_tg.arn
 }
}

resource "aws_lb_target_group" "ecs_tg" {
 name        = "ecs-target-group"
 port        = 80
 protocol    = "HTTP"
 target_type = "ip"
 vpc_id      = var.vpc_id

 health_check {
   path = "/"
 }
}
resource "aws_ecs_cluster" "ecs_cluster" {
 name = "my-ecs-cluster"
}
resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
 name = "test1"

 auto_scaling_group_provider {
   auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn

   managed_scaling {
     maximum_scaling_step_size = 1000
     minimum_scaling_step_size = 1
     status                    = "ENABLED"
     target_capacity           = 3
   }
 }
}

resource "aws_ecs_cluster_capacity_providers" "example" {
 cluster_name = aws_ecs_cluster.ecs_cluster.name

 capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]

 default_capacity_provider_strategy {
   base              = 1
   weight            = 100
   capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
 }
}
resource "aws_ecs_task_definition" "ecs_task_definition" {
 family             = "my-ecs-task"
 network_mode       = "awsvpc"
 execution_role_arn = "arn:aws:iam::000000000000:role/ecsTaskExecutionRole"
 cpu                = 256
 runtime_platform {
   operating_system_family = "LINUX"
   cpu_architecture        = "X86_64"
 }
 container_definitions = jsonencode([
   {
     name      = "dockergs"
     image     = "public.ecr.aws/f9n5f1l7/dgs:latest"
     cpu       = 256
     memory    = 512
     essential = true
     portMappings = [
       {
         containerPort = 80
         hostPort      = 80
         protocol      = "tcp"
       }
     ]
   }
 ])
}
# resource "aws_ecs_service" "ecs_service" {
#  name            = "my-ecs-service"
#  cluster         = aws_ecs_cluster.ecs_cluster.id
#  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
#  desired_count   = 2

#  network_configuration {
#    subnets         =  [for subnet in var.subnet_public : subnet]
#    security_groups = [var.vpc_security_group_ids]
#  }

#  force_new_deployment = true
#  placement_constraints {
#    type = "distinctInstance"
#  }

#  triggers = {
#    redeployment = timestamp()
#  }

#  capacity_provider_strategy {
#    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
#    weight            = 100
#  }

#  load_balancer {
#    target_group_arn = aws_lb_target_group.ecs_tg.arn
#    container_name   = "dockergs"
#    container_port   = 80
#  }

#  depends_on = [aws_autoscaling_group.ecs_asg]
# }