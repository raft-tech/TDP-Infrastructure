resource "aws_lb" "tdpraft" {
  name               = "tdp-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tdp_lb.id]
  subnets            = module.base_network.public_subnets_ids

  enable_deletion_protection = false

  tags = {
    Environment = "development"
  }
}

resource "aws_lb_target_group" "nexus_ui" {
  name     = "nexus-ui"
  port     = 8081
  protocol = "HTTP"
  vpc_id   = module.base_network.vpc_id
  health_check {
    port = 8081
  }
}

resource "aws_lb_target_group" "nexus_docker" {
  name     = "nexus-docker"
  port     = 8082
  protocol = "HTTP"
  vpc_id   = module.base_network.vpc_id
  health_check {
    port = 8081
  }
}

resource "aws_lb_target_group" "nexus_ssh" {
  name     = "nexus-ssh"
  port     = 22
  protocol = "HTTP"
  vpc_id   = module.base_network.vpc_id
}

resource "aws_lb_target_group_attachment" "nexus" {
  target_group_arn = aws_lb_target_group.nexus_ui.arn
  target_id        = aws_instance.nexus_server.id
  port             = 8081
}

resource "aws_lb_target_group_attachment" "nexus_docker" {
  target_group_arn = aws_lb_target_group.nexus_docker.arn
  target_id        = aws_instance.nexus_server.id
  port             = 8082
}

resource "aws_lb_target_group_attachment" "nexus_ssh" {
  target_group_arn = aws_lb_target_group.nexus_ssh.arn
  target_id        = aws_instance.nexus_server.id
  port             = 22
}

resource "aws_lb_listener" "tdpraft" {
  load_balancer_arn = aws_lb.tdpraft.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.tdpraft.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nexus_ui.arn
  }
}

resource "aws_lb_listener" "docker" {
  load_balancer_arn = aws_lb.tdpraft.arn
  port              = "8082"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.tdpraft.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nexus_docker.arn
  }
}

resource "aws_lb_listener" "tdpraft_ssh" {
  load_balancer_arn = aws_lb.tdpraft.arn
  port              = "22"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nexus_ssh.arn
  }
}

resource "aws_lb_listener" "tdpraft_redirect" {
  load_balancer_arn = aws_lb.tdpraft.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# resource "aws_lb_listener_rule" "nexus_docker" {
#   listener_arn = aws_lb_listener.docker.arn
#   priority     = 1

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.nexus_docker.arn
#   }

#   condition {
#     path_pattern {
#       values = ["/nexus/*"]
#     }
#   }

#   condition {
#     host_header {
#       values = ["tdpraft.com"]
#     }
#   }
# }

# resource "aws_lb_listener_rule" "nexus" {
#   listener_arn = aws_lb_listener.tdpraft.arn
#   priority     = 100

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.nexus_ui.arn
#   }

#   condition {
#     path_pattern {
#       values = ["/nexus/*"]
#     }
#   }

#   condition {
#     host_header {
#       values = ["tdpraft.com"]
#     }
#   }
# }