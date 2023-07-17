resource "aws_security_group" "tdp_lb" {
  name = "tdp_lb"
  vpc_id = module.base_network.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "http_allow_all" {
  security_group_id = aws_security_group.tdp_lb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "https_allow_all" {
  security_group_id = aws_security_group.tdp_lb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_ingress_rule" "ssh_allow_all" {
  security_group_id = aws_security_group.tdp_lb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "docker_allow_all" {
  security_group_id = aws_security_group.tdp_lb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 8082
  ip_protocol = "tcp"
  to_port     = 8082
}

resource "aws_vpc_security_group_egress_rule" "egress_allow_all" {
  security_group_id = aws_security_group.tdp_lb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = -1
  ip_protocol = "all"
  to_port     = -1
}

resource "aws_security_group" "nexus" {
  name = "nexus_sg"
  vpc_id = module.base_network.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "nexus_allow_lb" {
  security_group_id = aws_security_group.nexus.id

  from_port   = 8081
  ip_protocol = "tcp"
  to_port     = 8082

  referenced_security_group_id = aws_security_group.tdp_lb.id
}

resource "aws_vpc_security_group_ingress_rule" "nexus_ssh_allow" {
  security_group_id = aws_security_group.nexus.id

  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22

  referenced_security_group_id = aws_security_group.tdp_lb.id
}