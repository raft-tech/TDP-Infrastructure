data "aws_route53_zone" "tdpraft" {
  name = "tdpraft.com"
}

resource "aws_acm_certificate" "tdpraft" {
  domain_name               = "tdpraft.com"
  subject_alternative_names = ["*.tdpraft.com"]
  validation_method         = "DNS"

  tags = {
    Environment = "development"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "tdpraft_domain_validation" {
  for_each = {
    for dvo in aws_acm_certificate.tdpraft.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.tdpraft.zone_id
}

resource "aws_acm_certificate_validation" "tdpraft" {
  certificate_arn         = aws_acm_certificate.tdpraft.arn
  validation_record_fqdns = [for record in aws_route53_record.tdpraft_domain_validation : record.fqdn]
}

resource "aws_route53_record" "lb_cname" {
  zone_id = data.aws_route53_zone.tdpraft.zone_id
  name    = "nexus.tdpraft.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.tdpraft.dns_name]
}
