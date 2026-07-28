locals {
  mandatory_tags = {
    Project     = "SolidaryTech"
    Environment = "Production"
    CostCenter  = "NGO-Core"
    Owner       = "aguilar.rafael14@gmail.com"
    ManagedBy   = "Terraform"
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = local.mandatory_tags
  }
}

# Provider secundário usado pelo bucket S3 de DR (Velero cross-region)
provider "aws" {
  alias  = "secondary"
  region = "us-west-2"

  default_tags {
    tags = local.mandatory_tags
  }
}
