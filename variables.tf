variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "alarms_config_path" {
  description = "Path to the alarms configuration JSON file"
  type        = string
}

variable "pagerduty_integration_url" {
  description = "The PagerDuty integration URL for CloudWatch alarms"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "log_anomalies" {
  description = "Configuration for log anomaly detection"
  type = object({
    enabled = bool
    log_groups = list(object({
      name = string
      patterns = list(string)
      slack_channel = string
    }))
    evaluation_periods = number
    period = number
    threshold = number
  })
  default = {
    enabled = false
    log_groups = []
    evaluation_periods = 1
    period = 300
    threshold = 0
  }
} 