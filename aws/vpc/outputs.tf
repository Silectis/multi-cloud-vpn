output "vpc_id" {
  value       = aws_vpc.main.id
  description = "the id of the vpc"
}

output "vpc_cidr_block" {
  value       = aws_vpc.main.cidr_block
  description = "the cidr block of the vpc"
}

output "private_route_table_id" {
  value = aws_route_table.private.id
  description = "the private route table of the vpc"
}

output "public_route_table_id" {
  value = aws_route_table.public.id
  description = "the public route table of the vpc"
}
