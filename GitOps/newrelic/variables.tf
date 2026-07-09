variable "newrelic_account_id" {
  description = "Account ID da conta New Relic."
  type        = number
}

variable "notification_channel_ids" {
  description = "Canais existentes para notificacao. Pode ficar vazio em laboratorio."
  type        = list(number)
  default     = []
}
