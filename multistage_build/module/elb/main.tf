resource "aws_lb" "example-alb" {
    name = "example-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups =  [
        var.sg-web-id
    ]
    subnets = [
        var.subnet-public-a-id,
        var.subnet-public-c-id
    ]
    access_logs {
        bucket = var.kimura-example-access-log-bucket
    }    
}

resource "aws_lb_target_group" "alb-web-target-group" {
    name = "example-alb-target-group"
    port = 80
    protocol = "HTTP"
    vpc_id = var.myVPC-id

    health_check {
        interval = 30
        path = "/index.html"
        port = 80
        timeout = 5
        unhealthy_threshold = 3
        matcher = 200
    }
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