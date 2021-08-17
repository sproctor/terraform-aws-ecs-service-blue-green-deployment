locals {
  target_groups = ["blue", "green"]
}

resource "aws_lb_target_group" "this" {
  count = "${length(local.target_groups)}"
  name  = "${var.service_name}-tg-${element(local.target_groups, count.index)}"

  port        = 80
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = var.health_check_path
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = var.lb_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.cert_arn

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.this.0.arn}"
  }
}

resource "aws_lb_listener_rule" "this" {
  count        = 2
  listener_arn = "${aws_lb_listener.this.arn}"

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