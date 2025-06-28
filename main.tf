#--- Locals ---#
locals {
  config = jsondecode(file(var.alarms_config_path))
  
  # Create maps for each alarm type, defaulting to empty maps if attributes are missing
  rds_alarms = {
    for alarm in try(local.config.rds_alarms, []) : alarm.name => alarm
  }
  
  cloudwatch_alarms = {
    for alarm in try(local.config.cloudwatch_alarms, []) : alarm.name => alarm
  }
  
  log_metric_filters = {
    for filter in try(local.config.log_metric_filters, []) : filter.log_group_name => filter
  }
}

#--- SNS ---#
resource "aws_sns_topic" "cloudwatch_to_pagerduty" {
  name = "${var.environment}-cloudwatch-to-pagerduty"
  tags = var.tags
}

resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.cloudwatch_to_pagerduty.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action = "sns:Publish"
        Resource = aws_sns_topic.cloudwatch_to_pagerduty.arn
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "pagerduty_subscription" {
  topic_arn = aws_sns_topic.cloudwatch_to_pagerduty.arn
  protocol  = "https"
  endpoint  = var.pagerduty_integration_url
}

#--- RDS Alarms ---#
resource "aws_cloudwatch_metric_alarm" "rds_alarms" {
  for_each = local.rds_alarms

  alarm_name          = "${var.environment}-${each.value.name}"
  alarm_description   = each.value.description
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  treat_missing_data  = "missing"
  alarm_actions       = [aws_sns_topic.cloudwatch_to_pagerduty.arn]
  ok_actions          = [aws_sns_topic.cloudwatch_to_pagerduty.arn]

  dimensions = each.value.dimensions

  tags = merge(var.tags, {
    Name = "${var.environment}-${each.value.name}"
  })
}

#--- CloudWatch Alarms ---#
resource "aws_cloudwatch_metric_alarm" "cloudwatch_alarms" {
  for_each = local.cloudwatch_alarms

  alarm_name          = "${var.environment}-${each.value.name}"
  alarm_description   = each.value.description
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  treat_missing_data  = "missing"
  alarm_actions       = [aws_sns_topic.cloudwatch_to_pagerduty.arn]
  ok_actions          = [aws_sns_topic.cloudwatch_to_pagerduty.arn]

  dimensions = each.value.dimensions

  tags = merge(var.tags, {
    Name = "${var.environment}-${each.value.name}"
  })
}

#--- Log Metric Filters and their Alarms ---#
resource "aws_cloudwatch_log_metric_filter" "log_filters" {
  for_each = {
    for filter in flatten([
      for group in local.log_metric_filters : [
        for f in group.filters : {
          key = "${group.log_group_name}-${f.metric_name}"
          log_group_name = group.log_group_name
          filter = f
        }
      ]
    ]) : filter.key => filter
  }

  name           = "${var.environment}-${each.value.filter.metric_name}"
  pattern        = each.value.filter.pattern
  log_group_name = each.value.log_group_name

  metric_transformation {
    name          = each.value.filter.metric_name
    namespace     = each.value.filter.namespace
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "log_alarms" {
  for_each = {
    for filter in flatten([
      for group in local.log_metric_filters : [
        for f in group.filters : {
          key = "${group.log_group_name}-${f.metric_name}"
          log_group_name = group.log_group_name
          filter = f
        }
      ]
    ]) : filter.key => filter
  }

  alarm_name          = "${var.environment}-${each.value.filter.metric_name}-alarm"
  alarm_description   = each.value.filter.description
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  metric_name         = each.value.filter.metric_name
  namespace           = each.value.filter.namespace
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.cloudwatch_to_pagerduty.arn]

  dimensions = {
    LogGroupName = each.value.log_group_name
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-${each.value.filter.metric_name}-alarm"
  })
}