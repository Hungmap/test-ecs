variable "security_group" {
  type = any
}
variable "subnets" {
    type = list(string)
  
}
variable "vpc_id" {
  type = string
}
variable "instance_public_id" {
  type =list(string)
}
variable "health_check" {
   type = map(string)
   default = {
      "timeout"  = "10"
      "interval" = "20"
      "path"     = "/"
      "port"     = "443"
      "protocol" ="HTTPS"
      "unhealthy_threshold" = "2"
      "healthy_threshold" = "3"
    }
}