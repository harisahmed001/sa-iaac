resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "${var.name}-redis-subnet-group"
  subnet_ids = [for s in data.aws_subnet.subnets : s.id]
}

resource "aws_security_group" "redis_sg" {
  name        = "${var.name}-redis-security-group"
  description = "Allow Redis inbound traffic"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "Redis from EKS"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    security_groups = [
      module.eks.cluster_primary_security_group_id,
      module.eks.cluster_security_group_id,
      module.eks.node_security_group_id,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-redis-security-group"
  }
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.name}-redis"
  engine               = "redis"
  node_type            = var.redis_node
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids   = [aws_security_group.redis_sg.id]
}
