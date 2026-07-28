resource "aws_sqs_queue" "donations_dlq" {
  name                      = "solidary-donations-dlq"
  message_retention_seconds = 345600

  tags = {
    Name = "solidary-donations-dlq"
  }
}

resource "aws_sqs_queue" "donations" {
  name                       = "solidary-donations"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 86400

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.donations_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Name = "solidary-donations"
  }
}

output "queue_url" {
  value = aws_sqs_queue.donations.url
}

output "queue_arn" {
  value = aws_sqs_queue.donations.arn
}
