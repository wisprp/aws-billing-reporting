# aws-billing-reporting
[![Go Report Card](https://goreportcard.com/badge/github.com/wisprp/aws-billing-reporting)](https://goreportcard.com/report/github.com/wisprp/aws-billing-reporting)

Small serverless service for monthly AWS usage reporting

The service sends notifications in Slack channel with aggregated costs for `Billing` tag in AWS

### Deployment

1. Copy `.env-sample` to `.env` and fill it. You need to specify only (`AWS_ACCESS_KEY` and `AWS_SECRET_ACCESS_KEY`) or `AWS_PROFILE` for terraform. User should be able to create new IAM roles/policies and use Lambda and CloudWatch services
2. Define `TF_VAR_SLACK_WEBHOOK_URL` as a Slack [incomming webhook](https://api.slack.com/messaging/webhooks) URL 
3. Load environment variables

```export $(xargs < .env)```

4. Compile and archive lambda function

 ```GOOS=linux go build main.go && zip main.zip main```

5. Deploy serivice to AWS using terraform 

```cd iac && terraform apply```


Schedule can be adjusted by modifying `schedule_expression` in `cost-reporter.tf` using rate or cron expressions: [AWS Scheduled Events](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html)


### Slack notification format

```
2020-05-01 - 2020-06-01
Projects hardware expences (AWS):
project_1: $232.32
project_x: $140.96
project_foo: $102.2
```