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
  role          = "${aws_iam_role.tf_lambda_billing_role.arn}"
  handler       = "main"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = "${filebase64sha256("../main.zip")}"

  runtime = "go1.x"

  environment {
    variables = {
      SLACK_WEBHOOK_URL = ""
      BILLING_IGNORE_LIST = ""
    }
  }
}