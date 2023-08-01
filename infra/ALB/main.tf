

data "aws_elb_service_account" "main" {}
resource "aws_s3_bucket" "b" {
  bucket = "my-tf-test-bucket-2023"
  

  tags = {
    Name        = "My bucket"
    #Environment = "Dev"
  }
}
resource "aws_s3_bucket_policy" "allow_ALB_access_log" {
  bucket = aws_s3_bucket.b.id
  policy = data.aws_iam_policy_document.allow_ALB_access_log.json
}
data "aws_iam_policy_document" "allow_ALB_access_log"{
   statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }

    actions = [
      "s3:PutObject"
    ]
    effect = "Allow"

    resources = [
      aws_s3_bucket.b.arn,
      "${aws_s3_bucket.b.arn}/*",
    ]
  } 
} 

# data "aws_acm_certificate" "tossl" {
#   domain   = "*.saigonict.org"
#   types       = ["AMAZON_ISSUED"]
#   most_recent = true
# }
resource "aws_lb" "alb_facing_internet" {
    name = "alb-facing-internet"
    internal = false
    load_balancer_type = "application"
    security_groups = [var.security_group]
    subnets = [for subnets in var.subnets :subnets]
    enable_cross_zone_load_balancing = true
    enable_waf_fail_open = true
    access_logs {
    bucket  = aws_s3_bucket.b.bucket
    prefix  = "test-lb"
    enabled = true
    
  }

  tags = {
    Name ="alb-test-vpc"
  }
}
resource "aws_lb_target_group" "public_tg" {
  name        = "tf-example-lb-tg"
  port        = 443
  protocol    = "HTTPS"
  target_type = "instance"
  vpc_id      = var.vpc_id
  health_check {
      healthy_threshold   = var.health_check["healthy_threshold"]
      interval            = var.health_check["interval"]
      unhealthy_threshold = var.health_check["unhealthy_threshold"]
      timeout             = var.health_check["timeout"]
      path                = var.health_check["path"]
      port                = var.health_check["port"]
      protocol                = var.health_check["protocol"]
  }

}
resource "aws_lb_target_group_attachment" "public_tg" {
  depends_on =[aws_lb_target_group.public_tg]
  for_each = {
    for i, v in var.instance_public_id : i => v 
  }
  target_group_arn = aws_lb_target_group.public_tg.arn
  target_id = each.value
  port = 443
}
resource "aws_lb_listener" "lb_listener_https" {
   load_balancer_arn    = aws_lb.alb_facing_internet.arn
   port                 = "80"
   protocol             = "HTTP"
  #  ssl_policy        = "ELBSecurityPolicy-2016-08"
  #  certificate_arn   = data.aws_acm_certificate.tossl.arn
   default_action {
    target_group_arn = aws_lb_target_group.public_tg.arn
    type             = "forward"
  }
}

