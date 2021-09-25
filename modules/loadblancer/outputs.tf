#loadbalancing.outputs.tf

output "lb_target_group_arn" {
  value = aws_lb_target_group.bazan_tg.arn
}
output "lb_endpoint" {
  value = aws_lb.bazan_lb.dns_name
}