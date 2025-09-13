output "function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.writer.function_name
}

output "role_arn" {
  description = "IAM role ARN used by the Lambda"
  value       = local.use_managed_role ? aws_iam_role.lambda[0].arn : var.role_arn
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.lg.name
}