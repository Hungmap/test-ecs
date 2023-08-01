variable "vpc" {
  type = any
}

variable "sg_public" {
  type = any
}
variable "sg_private" {
  type = any
  
}
variable "subnet_public" {
  type = any
  
}
variable "az" {
  type =list(string)
}
variable "subnet_private" {
  type = any
}