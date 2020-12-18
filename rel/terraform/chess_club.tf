terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-west-1"
}

variable app_subdomain {}
variable domain {}
variable rds_db_name {}
variable rds_instance {}
variable rds_password {}
variable rds_username {}
variable region {}

locals {
  additional_db_security_groups = []
  az_count                      = 2
  multi_az                      = true
}

# -----------------------------------------------------------------------------
# Create the certificate
# -----------------------------------------------------------------------------

resource "aws_acm_certificate" "chess_club" {
  domain_name       = "${var.app_subdomain}.${var.domain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------------------------------------------------------
# Validate the certificate
# -----------------------------------------------------------------------------

data "aws_route53_zone" "chess_club" {
  name = "${var.domain}."
}

resource "aws_route53_record" "chess_club_validation" {
  depends_on = [aws_acm_certificate.chess_club]
  for_each = {
    for dvo in aws_acm_certificate.chess_club.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      type    = dvo.resource_record_type
      record  = dvo.resource_record_value
    }
  }
  name    = each.value.name
  records = [each.value.record]
  type    = each.value.type
  zone_id = data.aws_route53_zone.chess_club.zone_id
  ttl     = 300
}

resource "aws_acm_certificate_validation" "chess_club" {
  certificate_arn         = aws_acm_certificate.chess_club.arn
  validation_record_fqdns = [for record in aws_route53_record.chess_club_validation : record.fqdn]
}

# -----------------------------------------------------------------------------
# Create VPC
# -----------------------------------------------------------------------------

# Fetch AZs in the current region
data "aws_availability_zones" "available" {
}

resource "aws_vpc" "chess_club" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = false

  tags = {
    Name = "chess_club"
  }
}

# Create var.az_count private subnets for RDS, each in a different AZ
resource "aws_subnet" "chess_club_private" {
  count             = local.az_count
  cidr_block        = cidrsubnet(aws_vpc.chess_club.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.chess_club.id

  tags = {
    Name = "chess_club #${count.index} (private)"
  }
}

# Create var.az_count public subnets for chess_club, each in a different AZ
resource "aws_subnet" "chess_club_public" {
  count                   = local.az_count
  cidr_block              = cidrsubnet(aws_vpc.chess_club.cidr_block, 8, local.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.chess_club.id
  map_public_ip_on_launch = true

  tags = {
    Name = "chess_club #${local.az_count + count.index} (public)"
  }
}

# IGW for the public subnet
resource "aws_internet_gateway" "chess_club" {
  vpc_id = aws_vpc.chess_club.id

  tags = {
    Name = "chess_club"
  }
}

# Route the public subnet traffic through the IGW
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.chess_club.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.chess_club.id
}

# -----------------------------------------------------------------------------
# Create security groups
# -----------------------------------------------------------------------------

# Internet to ALB
resource "aws_security_group" "chess_club_alb" {
  name        = "chess-club-alb"
  description = "Allow access on port 443 only to ALB"
  vpc_id      = aws_vpc.chess_club.id

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "chess_club_instance" {
  name          = "allow-all-chess-club"
  description   = "Allow all inbound ssh+http traffic"
  vpc_id        = aws_vpc.chess_club.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    protocol        = "tcp"
    from_port       = "80"
    to_port         = "80"
    security_groups = [aws_security_group.chess_club_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "chess_club" {
  key_name   = "chess_club_deploy"
  public_key = file("../chess_club_key.pub")
}

resource "aws_instance" "chess_club" {
  count                  = local.az_count
  ami                    = "ami-0418d0e1b0321f723"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.chess_club.key_name
  vpc_security_group_ids = [aws_security_group.chess_club_instance.id]
  subnet_id              = aws_subnet.chess_club_public[count.index].id
}

# SSH access to Bastion from allowed IPs

resource "aws_security_group" "chess_club_bastion" {
  name        = "chess-club-bastion"
  description = "allow SSH access to chess_club bastion"
  vpc_id      = aws_vpc.chess_club.id

  ingress {
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    cidr_blocks     = ["0.0.0.0/0"] // TODO: Restrict to certain ip addresses?
    security_groups = local.additional_db_security_groups
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS to RDS

resource "aws_security_group" "chess_club_rds" {
  name        = "chess-club-rds"
  description = "allow inbound access from the chess_club tasks only"
  vpc_id      = aws_vpc.chess_club.id

  ingress {
    protocol        = "tcp"
    from_port       = "5432"
    to_port         = "5432"
    security_groups = concat([aws_security_group.chess_club_instance.id, aws_security_group.chess_club_bastion.id], local.additional_db_security_groups)
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -----------------------------------------------------------------------------
# Create Bastion host
# -----------------------------------------------------------------------------

data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "product-code"
    values = ["aw0evgkw8e5c1q413zgy5pjce"]
  }

  owners = ["aws-marketplace"]
}

resource "aws_instance" "bastion" {
  count                       = local.az_count
  ami                         = data.aws_ami.centos.id
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.chess_club.key_name
  subnet_id                   = aws_subnet.chess_club_public[count.index].id
  vpc_security_group_ids      = [aws_security_group.chess_club_bastion.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 10
    delete_on_termination = true
  }

  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name = "chess_club Bastion (#${count.index})"
  }
}

# -----------------------------------------------------------------------------
# Create RDS
# -----------------------------------------------------------------------------

resource "aws_db_subnet_group" "chess_club" {
  name       = "chess_club"
  subnet_ids = aws_subnet.chess_club_private.*.id
}

resource "aws_db_instance" "chess_club" {
  name                        = var.rds_db_name
  identifier                  = "chess-club"
  username                    = var.rds_username
  password                    = var.rds_password
  port                        = "5432"
  engine                      = "postgres"
  engine_version              = "12.4"
  instance_class              = var.rds_instance
  allocated_storage           = "10"
  storage_encrypted           = false
  vpc_security_group_ids      = [aws_security_group.chess_club_rds.id]
  db_subnet_group_name        = aws_db_subnet_group.chess_club.name
  parameter_group_name        = "default.postgres12"
  multi_az                    = local.multi_az
  storage_type                = "gp2"
  publicly_accessible         = false
  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = false
  apply_immediately           = true
  maintenance_window          = "sun:02:00-sun:04:00"
  skip_final_snapshot         = false
  copy_tags_to_snapshot       = true
  backup_retention_period     = 7
  backup_window               = "04:00-06:00"
  final_snapshot_identifier   = "chess-club"

  lifecycle {
    prevent_destroy = true
  }
}

# -----------------------------------------------------------------------------
# Create the ALB log bucket
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "chess_club" {
  bucket        = "chess-club-${var.region}-${var.app_subdomain}-${var.domain}"
  acl           = "private"
  force_destroy = "true"
}

# -----------------------------------------------------------------------------
# Add IAM policy to allow the ALB to log to it
# -----------------------------------------------------------------------------

data "aws_elb_service_account" "main" {
}

data "aws_iam_policy_document" "chess_club" {
  statement {
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.chess_club.arn}/alb/*"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "chess_club" {
  bucket = aws_s3_bucket.chess_club.id
  policy = data.aws_iam_policy_document.chess_club.json
}

# -----------------------------------------------------------------------------
# Create the ALB
# -----------------------------------------------------------------------------

resource "aws_alb" "chess_club" {
  name            = "chess-club-alb"
  subnets         = aws_subnet.chess_club_public.*.id
  security_groups = [aws_security_group.chess_club_alb.id]

  access_logs {
    bucket  = aws_s3_bucket.chess_club.id
    prefix  = "alb"
    enabled = true
  }
}

# -----------------------------------------------------------------------------
# Create the ALB target group for EC2
# -----------------------------------------------------------------------------

resource "aws_alb_target_group" "chess_club" {
  name        = "chess-club-alb"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.chess_club.id
  target_type = "instance"

  health_check {
    path    = "/version"
    matcher = "200"
  }
}

resource "aws_alb_target_group_attachment" "chess_club" {
  count             = local.az_count
  target_group_arn  = aws_alb_target_group.chess_club.arn
  target_id         = aws_instance.chess_club[count.index].id
  port              = 80
}

# -----------------------------------------------------------------------------
# Create the ALB listeners
# -----------------------------------------------------------------------------

# Forward on HTTPS
resource "aws_alb_listener" "chess_club_https" {
  load_balancer_arn = aws_alb.chess_club.id
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.chess_club.arn

  default_action {
    target_group_arn = aws_alb_target_group.chess_club.id
    type             = "forward"
  }
}

# Redirect HTTP to HTTPS
resource "aws_alb_listener" "chess_club_http" {
  load_balancer_arn = aws_alb.chess_club.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# -----------------------------------------------------------------------------
# Create Route 53 record to point to the ALB
# -----------------------------------------------------------------------------

resource "aws_route53_record" "chess_club" {
  zone_id = data.aws_route53_zone.chess_club.zone_id
  name    = "${var.app_subdomain}.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_alb.chess_club.dns_name
    zone_id                = aws_alb.chess_club.zone_id
    evaluate_target_health = true
  }
}