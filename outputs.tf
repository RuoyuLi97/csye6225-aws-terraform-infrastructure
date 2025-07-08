output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.gw.id
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}

output "webapp_sg_id" {
  value = aws_security_group.webapp_sg.id
}

output "mysql_sg_id" {
  value = aws_security_group.mysql_sg.id
}

output "mysql_instance_id" {
  value = aws_instance.mysql_instance.id
}

output "mysql_private_ip" {
  value = aws_instance.mysql_instance.private_ip
}

output "webapp_instance_id_1" {
  value = aws_instance.webapp_instance[0].id
}

output "webapp_instance_id_2" {
  value = aws_instance.webapp_instance[1].id
}

output "webapp_instance_id_3" {
  value = aws_instance.webapp_instance[2].id
}

output "webapp_private_ip_1" {
  value = aws_instance.webapp_instance[0].private_ip
}

output "webapp_private_ip_2" {
  value = aws_instance.webapp_instance[1].private_ip
}

output "webapp_private_ip_3" {
  value = aws_instance.webapp_instance[2].private_ip
}

output "webapp_public_ip_1" {
  value = aws_instance.webapp_instance[0].public_ip
}

output "webapp_public_ip_2" {
  value = aws_instance.webapp_instance[1].public_ip
}

output "webapp_public_ip_3" {
  value = aws_instance.webapp_instance[2].public_ip
}

output "nlb_dns_name" {
  value = aws_lb.api_nlb.dns_name
}