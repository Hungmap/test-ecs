variable "vpc_cidr_block" {
  type    = string
  default = "172.17.0.0/16"
}
variable "Public_subnet" {
  type = list(string)
}
variable "Private_subnet" {
  type = list(string)

}
variable "az" {
  type = list(string)
  default = [ "ap-northeast-1a","ap-northeast-1c" ]
}