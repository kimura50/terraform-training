resource "aws_launch_template" "web-template" {
    name = "web-template"
    image_id = data.aws_ssm_parameter.amzn2_ami.value
    instance_type = "t3.nano"
    key_name = "admin_test_key"
    monitoring {
        enabled = true
    }
    network_interfaces {
        associate_public_ip_address = true
        security_groups = [
            aws_security_group.admin.id
        ]
    }
    block_device_mappings {
        device_name = "/dev/xvda"
        ebs {
            volume_type = "gp2"
            volume_size = 20
            delete_on_termination = "true"
        }
    }
    block_device_mappings {
        device_name = "/dev/sdb"
        ebs {
            volume_type = "gp2"
            volume_size = 20
            delete_on_termination = "true"
        }
    }
    instance_market_options {
        market_type = "spot"
    }
    user_data = "${base64encode(local.userdata)}"
}

resource "aws_autoscaling_group" "web-autoscale-a" {
    name = "web-autoscale-a"
    launch_template {
        id = aws_launch_template.web-template.id
        version = aws_launch_template.web-template.latest_version
    }
    vpc_zone_identifier = [aws_subnet.public-a.id]
    target_group_arns = [aws_lb_target_group.alb-web-target-group.arn]
    max_size = 3
    min_size = 1
    desired_capacity = 1
    force_delete = true
    health_check_grace_period = 120
    health_check_type = "ELB"
}

resource "aws_autoscaling_group" "web-autoscale-c" {
    name = "web-autoscale-c"
    launch_template {
        id = aws_launch_template.web-template.id
        version = aws_launch_template.web-template.latest_version
    }
    target_group_arns = [aws_lb_target_group.alb-web-target-group.arn]
    vpc_zone_identifier = [aws_subnet.public-c.id]
    max_size = 3
    min_size = 1
    desired_capacity = 1
    force_delete = true
    health_check_grace_period = 120
    health_check_type = "ELB"
}
# グループ作って、スケールポリシー作って、ELBとの紐付けする
# さらにカスタムメトリクス参照するならそれも作る
resource "aws_autoscaling_policy" "autoscale-cpu-a" {
    name = "autoscale-cpu-a"
    autoscaling_group_name = aws_autoscaling_group.web-autoscale-a.name
    policy_type = "TargetTrackingScaling"
    target_tracking_configuration {
        predefined_metric_specification {
            predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 75.0
    }
}

resource "aws_autoscaling_policy" "autoscale-cpu-c" {
    name = "autoscale-cpu-c"
    autoscaling_group_name = aws_autoscaling_group.web-autoscale-a.name
    policy_type = "TargetTrackingScaling"
    target_tracking_configuration {
        predefined_metric_specification {
            predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 75.0
    }
}