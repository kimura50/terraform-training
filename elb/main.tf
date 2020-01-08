provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region = var.region
}

data aws_ssm_parameter amzn2_ami {
    name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

locals {
    userdata = <<USERDATA
#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
sudo yum -y update
sudo yum install -y httpd
sudo systemctl enable httpd
sudo systemctl restart httpd
hostname | sudo tee -a /var/www/html/index.html
USERDATA
}

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

resource "aws_subnet" "public-a" {
    vpc_id = aws_vpc.myVPC.id
    cidr_block = "10.1.1.0/24"
    availability_zone = "ap-northeast-1a"
}

resource "aws_subnet" "public-c" {
    vpc_id = aws_vpc.myVPC.id
    cidr_block = "10.1.2.0/24"
    availability_zone = "ap-northeast-1c"
}

resource "aws_route_table" "public-route" {
    vpc_id = aws_vpc.myVPC.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myGW.id
    }
}

resource "aws_route_table_association" "public-a" {
    subnet_id = aws_subnet.public-a.id
    route_table_id = aws_route_table.public-route.id
}

resource "aws_route_table_association" "public-c" {
    subnet_id = aws_subnet.public-c.id
    route_table_id = aws_route_table.public-route.id
}

resource "aws_security_group" "admin" {
    name = "admin"
    description = "Allow SSH inbound"
    vpc_id = aws_vpc.myVPC.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_iam_instance_profile" "ec2-access-role-profile" {
    name = "ec2-access-role-profile"
    role = aws_iam_role.ec2-access-role.name
}

resource "aws_iam_role" "ec2-access-role" {
    name = "ec2-access-role"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement" : [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "ec2-s3-access-role-policy" {
    name = "ec2-s3-access-role-policy"
    role = aws_iam_role.ec2-access-role.id
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement" : [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_s3_bucket" "kimura-example-access-log-bucket" {
    bucket = "kimura-example-access-log-bucket"
    acl = "log-delivery-write"
}

resource "aws_lb" "example-alb" {
    name = "example-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups =  [
        aws_security_group.admin.id
    ]
    subnets = [
        aws_subnet.public-a.id,
        aws_subnet.public-c.id
    ]
    access_logs {
        bucket = aws_s3_bucket.kimura-example-access-log-bucket.bucket
    }    
}

resource "aws_lb_target_group" "alb-web-target-group" {
    name = "example-alb-target-group"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.myVPC.id

    health_check {
        interval = 30
        path = "/index.html"
        port = 80
        timeout = 5
        unhealthy_threshold = 3
        matcher = 200
    }
}

resource "aws_lb_target_group_attachment" "alb-web1-attachment" {
    target_group_arn = aws_lb_target_group.alb-web-target-group.arn
    target_id = aws_instance.example-web1.id
    port = 80
}

resource "aws_lb_target_group_attachment" "alb-web2-attachment" {
    target_group_arn = aws_lb_target_group.alb-web-target-group.arn
    target_id = aws_instance.example-web2.id
    port = 80
}

resource "aws_lb_listener" "alb-web-listener" {
    load_balancer_arn = aws_lb.example-alb.arn
    port = 80
    protocol = "HTTP" 

    default_action {
        target_group_arn = aws_lb_target_group.alb-web-target-group.arn
        type = "forward"
    }
}

resource "aws_instance" "example-web1" {
    ami           = data.aws_ssm_parameter.amzn2_ami.value
    instance_type = "t2.nano"
    key_name = "admin_test_key"
    vpc_security_group_ids = [
        aws_security_group.admin.id
    ]
    subnet_id = aws_subnet.public-a.id
    associate_public_ip_address = "true"
    root_block_device {
      volume_type = "gp2"
      volume_size = "20"
    }
    ebs_block_device {
      device_name = "/dev/sdf"
      volume_type = "gp2"
      volume_size = "100"
    }
    iam_instance_profile = "ec2-access-role-profile"
    user_data_base64 = "${base64encode(local.userdata)}"
    tags = {
        Name = "example-web1"
    }
}

resource "aws_instance" "example-web2" {
    ami           = data.aws_ssm_parameter.amzn2_ami.value
    instance_type = "t2.nano"
    key_name = "admin_test_key"
    vpc_security_group_ids = [
        aws_security_group.admin.id
    ]
    subnet_id = aws_subnet.public-c.id
    associate_public_ip_address = "true"
    root_block_device {
      volume_type = "gp2"
      volume_size = "20"
    }
    ebs_block_device {
      device_name = "/dev/sdf"
      volume_type = "gp2"
      volume_size = "50"
    }
    iam_instance_profile = "ec2-access-role-profile"
    user_data_base64 = "${base64encode(local.userdata)}"
    tags = {
        Name = "example-web2"
    }
}