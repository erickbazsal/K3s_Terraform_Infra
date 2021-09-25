#main/variables
variable "aws_region" {
  default = "us-west-2"
}
variable "access_ip" {
  type = string
}

variable "dbname" {
  type = string
}
variable "dbuser" {
  type      = string
  sensitive = true
}
variable "dbpassword" {
  type      = string
  sensitive = true
}