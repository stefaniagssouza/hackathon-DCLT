variable "subnet_ids" {
  description = "Subnets privadas para o RDS"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "db_password" {
  description = "Senha do banco de dados"
  type        = string
  sensitive   = true
  default     = "solidary123"
}

resource "aws_db_subnet_group" "postgres" {
  name       = "solidarytech-db-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "rds" {
  name   = "solidarytech-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "solidarytech-rds-sg"
  }
}

# Instância única — ngo_db e donation_db criados via init.sql após o deploy
resource "aws_db_instance" "postgres" {
  identifier        = "solidarytech-postgres"
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "ngo_db"
  username = "postgres"
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  skip_final_snapshot = true
  deletion_protection = false
  multi_az            = false
  publicly_accessible = false

  # Backup retido por 1 dia — suporta RPO de 1h via automated backups
  backup_retention_period = 1
  backup_window           = "03:00-04:00"

  tags = {
    Name = "solidarytech-postgres"
  }
}
