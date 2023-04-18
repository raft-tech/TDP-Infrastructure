module "base_network" {
  source                                      = "cn-terraform/networking/aws"
  name_prefix                                 = "tdrs-networking"
  vpc_cidr_block                              = "192.168.0.0/16"
  availability_zones                          = ["us-east-1a", "us-east-1b"]
  public_subnets_cidrs_per_availability_zone  = ["192.168.0.0/19", "192.168.32.0/19"]
  private_subnets_cidrs_per_availability_zone = ["192.168.128.0/19", "192.168.160.0/19"]
}

# resource "aws_acm_certificate" "cert" {
#   domain_name       = "example.com"
#   validation_method = "DNS"

#   tags = {
#     Environment = "test"
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_route53_record" "www" {
#   zone_id = aws_route53_zone.primary.zone_id
#   name    = "www.example.com"
#   type    = "A"
#   ttl     = 300
#   records = [aws_eip.lb.public_ip]
# }

resource "aws_security_group" "tdp_alb" {
  name = "tdp_alb"
  vpc_id = module.base_network.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "http_allow_all" {
  security_group_id = aws_security_group.tdp_alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "docker8081_allow_all" {
  security_group_id = aws_security_group.tdp_alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 8081
  ip_protocol = "tcp"
  to_port     = 8081
}

resource "aws_alb" "tdp" {
  name               = "tdp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tdp_alb.id]
  subnets            = module.base_network.public_subnets_ids

  enable_deletion_protection = false

  tags = {
    Environment = "POC"
  }
}

resource "aws_iam_role" "k8s" {
  name = "tdp-infrastructure-role"
  description = "AWS Role to give EKS cluster permissions for TDP Infrastructure"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "EKS-cluster-policy"
  roles      = [aws_iam_role.k8s.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy" # AWS managed policy
}


# resource "aws_ecs_task_definition" "nexus_service" {
#   family = "nexus-service"
#   requires_compatibilities = ["FARGATE"]
#   cpu                      = 1024
#   memory                   = 2048
#   network_mode             = "awsvpc"
#   container_definitions = jsonencode([
#     {
#       name      = "nexus-docker"
#       image     = "sonatype/nexus3:latest"
#       cpu       = 1024
#       memory    = 2048
#       essential = true
#       portMappings = [
#         {
#           containerPort = 80
#           hostPort      = 80
#         },
#         {
#           containerPort = 8081
#           hostPort      = 8081
#         }
#       ]
#     }
#   ])

#   volume {
#     name      = "nexus-storage"
#   }

#   runtime_platform {
#     operating_system_family = "LINUX"
#     cpu_architecture        = "X86_64"
#   }
# }

# resource "aws_ecs_cluster" "nexus" {
#   name = "white-hart"

#   setting {
#     name  = "containerInsights"
#     value = "enabled"
#   }
# }