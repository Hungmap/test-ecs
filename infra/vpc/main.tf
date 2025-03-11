resource "aws_vpc" "test_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "test_vpc"
  }

}
resource "aws_subnet" "public" {
  count                   = length(var.Public_subnet)
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = var.Public_subnet[count.index]
  map_public_ip_on_launch = true
  availability_zone       = var.az[count.index % length(var.az)]

  tags = {
    Name = format("test_vpc_demo_public_subnet_%s", var.az[count.index])
  }
}
resource "aws_subnet" "private" {
  count             = length(var.Private_subnet)
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = var.Private_subnet[count.index]
  availability_zone = var.az[count.index % length(var.az)]
  tags = {
    Name = format("test_vpc_demo_private_subnet_%s", var.az[count.index])
  }

}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.test_vpc.id
  tags = {
    Name = "demo_vpc_igw"
  }
}
resource "aws_eip" "eip" {
  count = length(var.Public_subnet)
  vpc   = true
  tags = {
    Name = format("testvpc_eip_nat_%s", var.az[count.index]),
  }


}
resource "aws_nat_gateway" "nat_gateway" {
  #vpc = true
  depends_on = [aws_internet_gateway.igw]

  allocation_id = aws_eip.eip[0].id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = format("testvpc_public_nat_%s", var.az[0]),
  }
}
resource "aws_route_table" "pulic" { 
  vpc_id = aws_vpc.test_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "testvpc_route_public"
  }

}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.test_vpc.id
  #count  = length(var.Private_subnet)
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name = "testvpc_route_private"
  }

}
resource "aws_route_table_association" "association_public" {
  for_each = {
    for i, v in aws_subnet.public : i => v
  }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.pulic.id
}
resource "aws_route_table_association" "association_private" {
  for_each = {

    for k,v in aws_subnet.private : k => v
  }
  subnet_id = each.value.id
  route_table_id = aws_route_table.private.id

}

resource "aws_security_group" "public" {
  name        = "allow ssh and http public"
  description = "Allow SSH access from internet"
  vpc_id      = aws_vpc.test_vpc.id
  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "allow ssh from internet"
    from_port        = 22
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 22
    },
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "allow HTTPs"
      from_port        = 443
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 443
  },
  {
    cidr_blocks      = ["0.0.0.0/0"]
      description      = "allow RDP"
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80

  }]
  egress = [{
    description      = "for all outgoing traffics"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]
}
resource "aws_security_group" "private" {
  name        = "allow 3306"
  description = "allow connect mysql from public_subnet"
  vpc_id      = aws_vpc.test_vpc.id
  ingress = [{
    cidr_blocks      = []
    description      = "allow ssh from internet public subnet"
    from_port        = 22
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = [aws_security_group.public.id]
    self             = false
    to_port          = 22
    },
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "allow HTTP"
      from_port        = 3306
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = [aws_security_group.public.id]
      self             = false
      to_port          = 3306
  }]
  egress = [{
    description      = "for all outgoing traffics"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]
}
resource "aws_security_group" "alb_public" {
  name = "alb"
  description="alb_facing_internet"
  vpc_id = aws_vpc.test_vpc.id
  ingress = [ {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "alb_facing_internet"
    from_port = 443
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    protocol = "tcp"
    security_groups = []
    self = false
    to_port = 443
  } ]
  egress = [ {
    description      = "for all outgoing traffics"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]
}


