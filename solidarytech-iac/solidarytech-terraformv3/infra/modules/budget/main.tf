variable "alert_email" {
  description = "E-mail para alertas de orçamento"
  type        = string
}

variable "limit_amount" {
  description = "Limite de custo mensal em USD"
  type        = string
  default     = "40"
}

resource "aws_budgets_budget" "solidarytech" {
  name         = "solidarytech-monthly-budget"
  budget_type  = "COST"
  limit_amount = var.limit_amount
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.alert_email]
  }
}
