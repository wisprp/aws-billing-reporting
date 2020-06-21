# aws-billing-reporting
Small serverless service for monthly AWS usage reporting


Cretate AWS user for getting billing data and attach existing `Billing` and `Cost-Explorer`

```
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
```

In order to buid lambda function download, build and archive lambda package

```
go get github.com/aws/aws-lambda-go/lambda
GOOS=linux go build main.go
```

Explicitely Load environment variables from .env before local invocation

```
export $(xargs < .env)
```


aws lambda create-function --function-name billing-reporting --zip-file fileb://main.zip --handler main --runtime go1.x --role arn:aws:iam::548271326349:role/billing-and-cost-explorer-role