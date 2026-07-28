variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
  default     = "solidarytech-eks"
}

variable "labrole_arn" {
  description = "LabRole do AWS Academy — usada pelo cluster e nodes"
  type        = string
  default     = "arn:aws:iam::914963610886:role/LabRole"
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets do cluster (control plane)"
  type        = list(string)
}

variable "node_subnet_ids" {
  description = "Subnets do node group"
  type        = list(string)
}

resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = var.labrole_arn
  version  = "1.31"

  vpc_config {
    subnet_ids             = var.subnet_ids
    endpoint_public_access = true
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = false
  }

  tags = {
    Name = var.cluster_name
  }
}

resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "solidarytech-nodes"
  node_role_arn   = var.labrole_arn

  subnet_ids     = var.node_subnet_ids
  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  depends_on = [aws_eks_cluster.eks]

  tags = {
    Name = "solidarytech-node-group"
  }
}

# Acesso administrativo para a role voclabs (AWS Academy)
resource "aws_eks_access_entry" "voclabs" {
  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = "arn:aws:iam::914963610886:role/voclabs"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "voclabs_admin" {
  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = "arn:aws:iam::914963610886:role/voclabs"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.voclabs]
}
