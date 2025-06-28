# Basic Example: CloudWatch Alarms to PagerDuty

This example demonstrates the minimal usage of the `terraform-aws-cw-alarms-to-pagerduty` module. It provisions the required AWS resources to send CloudWatch alarm notifications to PagerDuty through SNS integration.

## Files
- `main.tf`: Terraform configuration for the example.
- `alarms.json`: Example CloudWatch alarm configuration file with RDS, CloudWatch, and Log Metric Filter alarms.

## Usage
To run this example:

```bash
terraform init
terraform plan
terraform apply
```

> **Note:** This example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

## Requirements
| Name      | Version |
|-----------|---------|
| terraform | >= 1.0  |
| aws       | >= 4.0  |

## What this example creates
- An SNS topic for alarm notifications
- SNS subscription to PagerDuty integration URL
- Sample RDS alarm (CPU utilization)
- Sample CloudWatch alarm (memory utilization)
- Sample Log Metric Filter alarm (error count)
- All required IAM roles and permissions

## Inputs
All values are pre-configured in the `main.tf` and `alarms.json` files for this example. See the module's documentation for all available variables.

## Outputs
See the module's documentation for available outputs.

---

*This example is maintained by Senora.dev.* 