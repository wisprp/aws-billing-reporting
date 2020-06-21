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

Explicitely Load environment variables from .env before local invocation

```
export $(xargs < .env)
```