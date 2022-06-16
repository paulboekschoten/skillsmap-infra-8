terraform {
  required_providers {
    acme = {
      source  = "vancluever/acme"
      version = "2.8.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "acme" {
  #server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

## resources
# RSA key of size 4096 bits
resource "tls_private_key" "rsa-4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# key pair
resource "aws_key_pair" "paul-tf" {
  key_name   = "paul-tf"
  public_key = tls_private_key.rsa-4096.public_key_openssh
}

# security group
resource "aws_security_group" "paul-sg-tf" {
  name = "paul-sg-tf"
}

# sg rule icmp inbound
resource "aws_security_group_rule" "allow_icmp_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.paul-sg-tf.id

  from_port   = local.any_icmp_port
  to_port     = local.any_icmp_port
  protocol    = local.icmp_protocol
  cidr_blocks = local.all_ips
}

# sg rule http inbound
resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.paul-sg-tf.id

  from_port   = var.http_port
  to_port     = var.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

# sg rule https inbound
resource "aws_security_group_rule" "allow_https_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.paul-sg-tf.id

  from_port   = var.https_port
  to_port     = var.https_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

# sg rule ssh inbound
resource "aws_security_group_rule" "allow_ssh_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.paul-sg-tf.id

  from_port   = var.ssh_port
  to_port     = var.ssh_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

# sg rule all outbound
resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.paul-sg-tf.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}

# EC2 instance
resource "aws_instance" "paul-web-tf" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.paul-tf.key_name
  vpc_security_group_ids = [aws_security_group.paul-sg-tf.id]

  tags = {
    Name = "paul-web-tf"
  }

}

## route53 fqdn
# fetch zone
data "aws_route53_zone" "selected" {
  name         = var.route53_zone
  private_zone = false
}
# create record
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.route53_subdomain}.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.paul-web-tf.public_ip]
}

## certficate let's encrypt
# create auth key
resource "tls_private_key" "cert_private_key" {
  algorithm = "RSA"
}

# register
resource "acme_registration" "registration" {
  account_key_pem = tls_private_key.cert_private_key.private_key_pem
  email_address   = var.cert_email
}
# get certificate
resource "acme_certificate" "certificate" {
  account_key_pem = acme_registration.registration.account_key_pem
  common_name     = aws_route53_record.www.name
  #subject_alternative_names = ["*.${aws_route53_record.www.name}"]

  dns_challenge {
    provider = "route53"

    config = {
      AWS_HOSTED_ZONE_ID = data.aws_route53_zone.selected.zone_id
    }
  }
}

resource "null_resource" "config" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.rsa-4096.private_key_pem
    host        = aws_instance.paul-web-tf.public_ip
  }

  provisioner "file" {
    content = templatefile("script.sh", {
      cert_path         = "/etc/letsencrypt/live/cloudinfrapaultf.tf-support.hashicorpdemo.com"
      fullchain_content = "${acme_certificate.certificate.certificate_pem}${acme_certificate.certificate.issuer_pem}"
      privkey_content   = nonsensitive(acme_certificate.certificate.private_key_pem)
    })
    destination = "/tmp/script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh",
    ]
  }

  triggers = {
    id = "5"
  }
}