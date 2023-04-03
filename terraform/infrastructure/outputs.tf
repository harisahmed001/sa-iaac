output "subnet_cidr_blocks" {
  description = "Subnets"
  value       = [for s in data.aws_subnet.subnets : s.id]
}

output "s3_bucket_website_endpoint" {
  description = "Static site domain"
  value       = try(aws_s3_bucket_website_configuration.website_conf.website_endpoint, "")
}

output "service_account" {
  description = "Service Account ARN"
  value       = aws_iam_role.eks-workload.arn
}

output "redis" {
  value = "${aws_elasticache_cluster.redis.cache_nodes[0].address}:${aws_elasticache_cluster.redis.cache_nodes[0].port}"
}
