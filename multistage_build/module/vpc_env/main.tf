resource "aws_subnet" "public-a" {
    vpc_id = var.myVPC-id
    cidr_block = "10.1.101.0/24"
    availability_zone = "ap-northeast-1a"
}

resource "aws_subnet" "public-c" {
    vpc_id = var.myVPC-id
    cidr_block = "10.1.102.0/24"
    availability_zone = "ap-northeast-1c"
}

resource "aws_subnet" "private-a" {
    vpc_id = var.myVPC-id
    cidr_block = "10.1.201.0/24"
    availability_zone = "ap-northeast-1a"
}

resource "aws_subnet" "private-c" {
    vpc_id = var.myVPC-id
    cidr_block = "10.1.202.0/24"
    availability_zone = "ap-northeast-1c"
}

resource "aws_eip" "nateip" {
    vpc = true
}

resource "aws_nat_gateway" "myNATGW" {
    subnet_id = var.bastion-subnet-public-a-id
    allocation_id = aws_eip.nateip.id
}

resource "aws_route_table" "private-route" {
    vpc_id = var.myVPC-id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.myNATGW.id
    }
}

resource "aws_route_table_association" "public-a" {
    subnet_id = aws_subnet.public-a.id
    route_table_id = var.public-route-id
}

resource "aws_route_table_association" "public-c" {
    subnet_id = aws_subnet.public-c.id
    route_table_id = var.public-route-id
}

resource "aws_route_table_association" "private-a" {
    subnet_id = aws_subnet.private-a.id
    route_table_id = aws_route_table.private-route.id
}

resource "aws_route_table_association" "private-c" {
    subnet_id = aws_subnet.private-c.id
    route_table_id = aws_route_table.private-route.id
}