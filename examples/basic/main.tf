provider "aws" {
  region = "us-east-1"
}

module "cw_alarms_to_pagerduty" {
  source = "../.."

  environment              = "dev"
  alarms_config_path       = "${path.module}/alarms.json"
  pagerduty_integration_url = "https://events.pagerduty.com/v2/enqueue/service/XXXXX"

  tags = {
    Project     = "ExampleProject"
    Environment = "dev"
  }
} 