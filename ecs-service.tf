resource "aws_ecs_service" "this" {
  name                 = "${var.service_name}"
  task_definition      = "${aws_ecs_task_definition.this.id}"
  cluster              = "${aws_ecs_cluster.this.arn}"
  desired_count        = var.service_count
  force_new_deployment = true

  load_balancer {
    target_group_arn = "${aws_lb_target_group.this.0.arn}"
    container_name   = "${var.service_name}"
    container_port   = "${var.container_port}"
  }

  launch_type                        = "FARGATE"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  depends_on = [aws_lb_listener.this]

  network_configuration {
    // security_groups  = [aws_security_group.ecs]
    subnets          = data.aws_subnet_ids.this.ids
    assign_public_ip = var.public_ip
  }

  lifecycle {
    ignore_changes = [
      load_balancer,
      desired_count,
      task_definition,
    ]
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 100
    base              = 1
  }
}

data "aws_subnet_ids" "this" {
  vpc_id = var.vpc_id
}