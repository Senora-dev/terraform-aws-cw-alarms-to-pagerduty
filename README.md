# CloudWatch to PagerDuty Alerts Terraform Module

A Terraform module for creating CloudWatch alarms that send notifications to PagerDuty through SNS integration.

## Features

- Creates CloudWatch alarms from JSON configuration
- Supports RDS, CloudWatch, and Log Metric Filter alarms
- Sets up SNS topic for alarm notifications
- Integrates with PagerDuty via HTTPS endpoint
- Configures necessary IAM roles and permissions
- Supports multiple environments
- Includes proper tagging

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Usage

1. Create your `alarms.json` file with your desired alarms configuration:

```json
{
  "rds_alarms": [
    {
      "name": "HighCPU",
      "description": "RDS CPU utilization is high",
      "metric_name": "CPUUtilization",
      "namespace": "AWS/RDS",
      "statistic": "Average",
      "period": 300,
      "evaluation_periods": 2,
      "threshold": 80,
      "comparison_operator": "GreaterThanThreshold",
      "dimensions": {
        "DBInstanceIdentifier": "my-database"
      }
    }
  ],
  "cloudwatch_alarms": [
    {
      "name": "HighMemory",
      "description": "EC2 memory utilization is high",
      "metric_name": "MemoryUtilization",
      "namespace": "AWS/EC2",
      "statistic": "Average",
      "period": 300,
      "evaluation_periods": 2,
      "threshold": 85,
      "comparison_operator": "GreaterThanThreshold",
      "dimensions": {
        "InstanceId": "i-0123456789abcdef0"
      }
    }
  ],
  "log_metric_filters": [
    {
      "log_group_name": "/aws/lambda/my-function",
      "filters": [
        {
          "metric_name": "ErrorCount",
          "namespace": "MyApp/Logs",
          "pattern": "ERROR",
          "description": "Error count in application logs"
        }
      ]
    }
  ]
}
```

2. Create a Terraform configuration file:

```hcl
module "cloudwatch_pagerduty_alerts" {
  source = "Senora-dev/cw-alarms-to-pagerduty/aws"

  environment              = "prod"
  alarms_config_path       = "./alarms.json"
  pagerduty_integration_url = "https://events.pagerduty.com/v2/enqueue/service/XXXXX"
  
  tags = {
    Project     = "MyProject"
    Environment = "Production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name (e.g., dev, staging, prod) | `string` | n/a | yes |
| alarms_config_path | Path to the alarms configuration JSON file | `string` | n/a | yes |
| pagerduty_integration_url | The PagerDuty integration URL for CloudWatch alarms | `string` | n/a | yes |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |
| log_anomalies | Configuration for log anomaly detection | `object` | See below | no |

### log_anomalies Object

```hcl
{
  enabled = bool
  log_groups = list(object({
    name = string
    patterns = list(string)
    slack_channel = string
  }))
  evaluation_periods = number
  period = number
  threshold = number
}
```

## Outputs

| Name | Description |
|------|-------------|
| sns_topic_arn | The ARN of the SNS topic used for CloudWatch alarms |
| cloudwatch_alarms | Map of CloudWatch alarm names to their ARNs |

## Examples

- [Basic Example](examples/basic) - Minimal usage with RDS and CloudWatch alarms.

## License

MIT Licensed. See [LICENSE](LICENSE) for full details.

## Maintainers

This module is maintained by [Senora.dev](https://senora.dev). 