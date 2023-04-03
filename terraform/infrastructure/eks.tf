module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.name
  cluster_version = "1.25"

  vpc_id                   = data.aws_vpc.selected.id
  subnet_ids               = [for s in data.aws_subnet.subnets : s.id]
  control_plane_subnet_ids = [for s in data.aws_subnet.subnets : s.id]


  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_enabled_log_types   = []
  create_kms_key              = false
  cluster_encryption_config   = {}
  create_cloudwatch_log_group = false

}

module "eks_managed_node_group" {
  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"

  name                              = "${var.name}-node-group"
  cluster_name                      = module.eks.cluster_name
  cluster_version                   = module.eks.cluster_version
  subnet_ids                        = [for s in data.aws_subnet.subnets : s.id]
  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id


  min_size     = 1
  max_size     = 2
  desired_size = 1

  instance_types = [var.instance_eks]
  capacity_type  = "ON_DEMAND"
}
