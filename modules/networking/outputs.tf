#networking/outputs
output "vpc_id" {
  value = aws_vpc.bazan_vpc.id

}

output "dbsub_id" {
  value = aws_db_subnet_group.bazan_rds_subnet_group[0].id
}
output "rds_sg" {
  value = aws_security_group.bazan_sg["rds"].id
}
output "public_sg" {
  value = aws_security_group.bazan_sg["public"].id
}
output "pub_subnets" {
  value = aws_subnet.Bazan_public_subnet.*.id
}
