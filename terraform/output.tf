output "cluster_id" {
  value = aws_eks_cluster.anub.id
}

output "node_group_id" {
  value = aws_eks_node_group.anub.id
}

output "vpc_id" {
  value = aws_vpc.anub_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.anub_subnet[*].id
}

