#loadblancer/variables.tf

variable "public_sg" {}
variable "public_subnets" {}
variable "lbname" {}
variable "port_tg_port" {}
variable "tg_protocol" {}
variable "vpc_id" {}
variable "lb_healthy_threshold" {}
variable "lb_unhealthy_threshold" {}
variable "lib_timeout" {}
variable "lb_interval" {}

variable "listener_port" {}
variable "listener_protocol" {}