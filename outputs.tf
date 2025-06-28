output "sns_topic_arn" {
  description = "The ARN of the SNS topic used for CloudWatch alarms"
  value       = aws_sns_topic.cloudwatch_to_pagerduty.arn
}

output "cloudwatch_alarms" {
  description = "Map of CloudWatch alarm names to their ARNs"
  value       = merge(
    { for k, v in aws_cloudwatch_metric_alarm.rds_alarms : k => v.arn },
    { for k, v in aws_cloudwatch_metric_alarm.cloudwatch_alarms : k => v.arn },
    { for k, v in aws_cloudwatch_metric_alarm.log_alarms : k => v.arn }
  )
} 