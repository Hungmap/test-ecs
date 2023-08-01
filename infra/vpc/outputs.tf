output "sg_public" {
  value = aws_security_group.public.id
}
output "sg_private" {
    value = aws_security_group.private.id
  
}
output "sg_alb" {
    value = aws_security_group.alb_public.id
  
}
output "subnet_public" {
    value = [for subnet in aws_subnet.public : subnet.id]
}
output "subnet_private" {
    value = [for subnet in aws_subnet.private : subnet.id]
}
output "vpc_id"{
    value = aws_vpc.test_vpc.id
}