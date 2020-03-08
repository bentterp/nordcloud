module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "notejam-test"
  cidr = "10.2.0.0/16"

  azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  private_subnets = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
  public_subnets  = ["10.2.101.0/24", "10.2.102.0/24", "10.2.103.0/24"]
  database_subnets = ["10.2.201.0/24", "10.2.202.0/24", "10.2.203.0/24"]

  enable_nat_gateway = false

  tags = {
    Terraform = "true"
    Environment = "test"
  }
}

resource "aws_security_group" "webserver" {
  name        = "allow_web"
  description = "Allow inbound website traffic"
  vpc_id      = module.vpc.vpc_id
}
resource "aws_security_group_rule" "allow_http" {
  type            = "ingress"
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.webserver.id
}
resource "aws_security_group_rule" "allow_https" {
  type            = "ingress"
  from_port       = 443
  to_port         = 443
  protocol        = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.webserver.id
}

resource "aws_security_group" "adminssh" {
  name        = "admin_ssh"
  description = "Allow inbound SSH traffic from adminhosts"
  vpc_id      = module.vpc.vpc_id
}
resource "aws_security_group_rule" "allow_hemterp_ssh"{
  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  cidr_blocks = [ "${data.dns_a_record_set.hemterp.addrs.0}/32"]
  security_group_id = aws_security_group.adminssh.id
}

resource "aws_security_group" "outboundanyany" {
  name        = "freeoutbound"
  description = "Allow any outbound traffic"
  vpc_id      = module.vpc.vpc_id
}
resource "aws_security_group_rule" "allow_outbound_tcp"{
  type            = "egress"
  from_port       = 0
  to_port         = 65535
  protocol        = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.outboundanyany.id
}

resource "aws_security_group_rule" "allow_outbound_udp"{
  type            = "egress"
  from_port       = 0
  to_port         = 65535
  protocol        = "udp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.outboundanyany.id
}

resource "aws_security_group_rule" "allow_outbound_icmp"{
  type            = "egress"
  from_port       = -1
  to_port         = -1
  protocol        = "icmp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.outboundanyany.id
}

data "dns_a_record_set" "hemterp" {
  host = "hem.terp.se"
}
