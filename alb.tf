locals {
  target_groups = ["blue", "green"]
}

resource "aws_lb_target_group" "this" {
  count = "${length(local.target_groups)}"
  name  = "${var.service_name}-tg-${element(local.target_groups, count.index)}"

  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = var.health_check_path
  }
}

resource "aws_lb_listener_rule" "this" {
  count        = 2
  listener_arn = var.lb_listener_arn

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.this.*.arn[count.index]}"
  }

  condition {
    host_header {
      values = var.host_names
    }
  }
}