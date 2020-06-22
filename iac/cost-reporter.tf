variable "SLACK_WEBHOOK_URL" {
  type = string
}
variable "BILLING_IGNORE_LIST" { 
  type = string
}

# Compile and archive lambda via local-exec provisioner 
# (will not force recreate package, need to find a way to force it)
resource "null_resource" "compile_app_and_archive" {
  provisioner "local-exec" {
    command = "cd .. && GOOS=linux go build main.go && zip main.zip main"
  }
}

resource "aws_iam_policy" "tf_billing_policy" {
  name        = "tf_billing_policy"
  path        = "/"
  description = "Alow getting billing information"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "aws-portal:*Billing",
                "awsbillingconsole:*Billing",
                "aws-portal:*Usage",
                "awsbillingconsole:*Usage",
                "aws-portal:*PaymentMethods",
                "awsbillingconsole:*PaymentMethods",
                "budgets:ViewBudget",
                "budgets:ModifyBudget",
                "cur:*",
                "purchase-orders:*PurchaseOrders",
                "ce:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


resource "aws_iam_role" "tf_lambda_billing_role" {
  name = "tf_lambda_billing_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "tf_billing_role_policy_attach" {
  role       = aws_iam_role.tf_lambda_billing_role.name
  policy_arn = aws_iam_policy.tf_billing_policy.arn
}

resource "aws_lambda_function" "billing_reporting_lambda" {
  filename      = "../main.zip"
  function_name = "tf_billing-reporting"
  role          = aws_iam_role.tf_lambda_billing_role.arn
  handler       = "main"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("../main.zip")

  runtime = "go1.x"

  environment {
    variables = {
      SLACK_WEBHOOK_URL = var.SLACK_WEBHOOK_URL
      BILLING_IGNORE_LIST = var.BILLING_IGNORE_LIST
    }
  }
}

resource "aws_cloudwatch_event_rule" "every_1st_day_of_month" {
    name = "every-five-minutes"
    description = "Fires every 1st day of the month"
    schedule_expression = "cron(1 8 1 * ? *)"
}

resource "aws_cloudwatch_event_target" "billing_report_every_1st_day_of_month" {
    rule = aws_cloudwatch_event_rule.every_1st_day_of_month.name
    target_id = "billing_reporting_lambda"
    arn = aws_lambda_function.billing_reporting_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_reporting_function" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.billing_reporting_lambda.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.every_1st_day_of_month.arn
}