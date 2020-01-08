resource "aws_vpc" "myVPC" {
    cidr_block = "10.1.0.0/16"
    instance_tenancy = "default"
    enable_dns_support = "true"
    enable_dns_hostnames = "false"
    tags = {
        Name = "myVPC"
    }
}

resource "aws_internet_gateway" "myGW" {
    vpc_id = aws_vpc.myVPC.id
}

resource "aws_route_table" "public-route" {
    vpc_id = aws_vpc.myVPC.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myGW.id
    }
}

resource "aws_subnet" "bastion-public-a" {
    vpc_id = aws_vpc.myVPC.id
    cidr_block = "10.1.1.0/24"
    availability_zone = "ap-northeast-1a"
}

resource "aws_route_table_association" "bastion-public-a" {
    subnet_id = aws_subnet.bastion-public-a.id
    route_table_id = aws_route_table.public-route.id
}

