#loadblancer/main.tf

resource "aws_lb" "bazan_lb" {
  name            = var.lbname
  subnets         = var.public_subnets
  security_groups = [var.public_sg]
  idle_timeout    = 400
  tags = merge(local.common_tags,
    map(
      "Name", var.lbname
    )
  )
}

resource "aws_lb_target_group" "bazan_tg" {
  name     = "bazan-lb-tg-${substr(uuid(), 0, 3)}"
  port     = var.port_tg_port
  protocol = upper(var.tg_protocol)
  vpc_id   = var.vpc_id
  lifecycle {
    ignore_changes = [name]
    create_before_destroy = true
  }
  health_check {
    healthy_threshold   = var.lb_healthy_threshold
    unhealthy_threshold = var.lb_unhealthy_threshold
    timeout             = var.lib_timeout
    interval            = var.lb_interval
  }
  tags = merge(local.common_tags,
    map(
      "Name", var.lbname,
      "LoadBalancer", aws_lb.bazan_lb.name
    )
  )
}
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.bazan_lb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bazan_tg.arn
  }
}