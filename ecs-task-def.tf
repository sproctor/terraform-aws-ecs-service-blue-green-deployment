resource "aws_ecs_task_definition" "this" {
  family                   = "${var.service_name}"
  execution_role_arn       = "${aws_iam_role.execution_role.arn}"
  task_role_arn            = "${aws_iam_role.task_role.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu                      = var.cpu_unit
  memory                   = var.memory

  container_definitions    = jsonencode([
        {
            essential = true
            image     = var.ecr_image_url
            name      = var.service_name
            portMappings = [
                {
                containerPort = var.container_port
                hostPort      = var.container_port
                protocol      = "tcp"
                }
            ]
            logConfiguration = {
                logDriver = "awslogs"
                options   = {
                    awslogs-region        = var.region
                    awslogs-group         = var.service_name
                    awslogs-stream-prefix = var.prefix_logs
                }
            }
            environment = concat(
                [
                    {
                        name  = "APP_NAME"
                        value = var.service_name
                    },
                    {
                        name  = "PORT"
                        value = tostring(var.container_port)
                    }
                ],
                var.environment_list
            )
        }
    ])
}

resource "aws_cloudwatch_log_group" "this" {
  name              = var.service_name
  retention_in_days = 14
}