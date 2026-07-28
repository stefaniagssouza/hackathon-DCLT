resource "aws_dynamodb_table" "volunteers" {
  name         = "SolidaryTechVolunteers"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "volunteer_id"

  attribute {
    name = "volunteer_id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name = "SolidaryTechVolunteers"
  }
}

output "table_name" {
  value = aws_dynamodb_table.volunteers.name
}
