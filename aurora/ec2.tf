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
      volume_size = "20"
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
      volume_size = "20"
    }
    iam_instance_profile = "ec2-access-role-profile"
    user_data_base64 = "${base64encode(local.userdata)}"
    tags = {
        Name = "example-web2"
    }
}