terraform {
  backend "s3" {
    # Preencha com o nome retornado pelo bootstrap
    bucket         = "solidarytech-tfstate-914963610886"
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    #dynamodb_table = "solidarytech-tfstate-lock"
  }
}
