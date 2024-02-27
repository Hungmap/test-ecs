variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}
variable "Public_subnet" {
  type = list(string)
}
variable "Private_subnet" {
  type = list(string)

}
variable "az" {
  type = list(string)
  default = [ "ap-southeast-1a","ap-southeast-1c" ]
}