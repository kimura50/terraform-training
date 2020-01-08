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

#resource "aws_lb_target_group_attachment" "alb-web1-attachment" {
#    target_group_arn = aws_lb_target_group.alb-web-target-group.arn
#    target_id = aws_instance.example-web1.id
#    port = 80
#}

#resource "aws_lb_target_group_attachment" "alb-web2-attachment" {
#    target_group_arn = aws_lb_target_group.alb-web-target-group.arn
#    target_id = aws_instance.example-web2.id
#    port = 80
#}

resource "aws_lb_listener" "alb-web-listener" {
    load_balancer_arn = aws_lb.example-alb.arn
    port = 80
    protocol = "HTTP" 

    default_action {
        target_group_arn = aws_lb_target_group.alb-web-target-group.arn
        type = "forward"
    }
}