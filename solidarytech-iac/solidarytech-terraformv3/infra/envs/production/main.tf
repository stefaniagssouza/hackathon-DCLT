module "networking" {
  source = "../../modules/networking"

  vpc_cidr = "10.0.0.0/16"
  region   = "us-east-1"
}

module "eks" {
  source = "../../modules/eks"

  vpc_id          = module.networking.vpc_id
  subnet_ids      = module.networking.public_subnets
  node_subnet_ids = module.networking.public_subnets
}

module "ecr" {
  source = "../../modules/ecr"

  repositories = [
    "ngo-service",
    "donation-service",
    "volunteer-service"
  ]
}

module "rds" {
  source = "../../modules/rds"

  subnet_ids = module.networking.private_subnets
  vpc_id     = module.networking.vpc_id
}

module "sqs" {
  source = "../../modules/sqs"
}

module "dynamodb" {
  source = "../../modules/dynamodb"
}

module "s3" {
  source = "../../modules/s3"
}

