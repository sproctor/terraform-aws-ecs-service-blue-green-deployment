output "ecs_service_id" {
  description = "ID of service created"
  value       = aws_ecs_service.this.id
}

output "ecs_task_arn" {
  description = "ARN of ecs task"
  value       = aws_ecs_task_definition.this.arn
}

output "codedeploy_group_id" {
  description = "Codedeploy group id"
  value       = aws_codedeploy_deployment_group.this.id
}
