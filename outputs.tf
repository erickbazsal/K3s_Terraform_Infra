#main/outputs.tf
output "lb_dns_lb" {
  value = module.lb.lb_endpoint
}
output "instances" {
    value = {for i in module.compute.instance : i.tags.Name => "${i.public_ip}:${module.compute.instance_port}" }
    sensitive = true
}