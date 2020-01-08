output "myVPC-id" {
  value = aws_vpc.myVPC.id 
}

output "myGW-id" {
  value = aws_internet_gateway.myGW.id 
}

output "public-route-id" {
  value = aws_route_table.public-route.id
}

output "bastion-subnet-public-a-id" {
  value = aws_subnet.bastion-public-a.id
}