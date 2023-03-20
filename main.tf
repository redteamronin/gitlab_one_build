terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.17.1"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "local_file" "cloud_init_gitlab_template" {
  content  = templatefile("${path.module}/cloud-init-gitlab.tmpl", { users = var.users_list, gitlab_domain = "gitlab.${var.domain}" })
  filename = "${path.module}/files/cloud-init-gitlab.yaml"
}

data "local_file" "cloud_init_gitlab_yaml" {
  filename   = local_file.cloud_init_gitlab_template.filename
  depends_on = [local_file.cloud_init_gitlab_template]
}

resource "aws_eip" "gitlab" {
  instance = aws_instance.gitlab.id
  vpc      = true
}

resource "aws_eip_association" "gitlab_eip_association" {
  instance_id   = aws_instance.gitlab.id
  allocation_id = aws_eip.gitlab.id
}

resource "aws_route53_record" "gitlab" {
  zone_id = var.route53_zone
  name    = "gitlab.${var.domain}"
  type    = "A"
  ttl     = 300
  records = [aws_eip_association.gitlab_eip_association.public_ip]
}

resource "aws_security_group" "gitlab" {
  name        = "gitlab_access"
  description = "Allow HTTP, HTTPS, SSH"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.ip_cidrs, "127.0.0.1/32"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ip_cidrs, "127.0.0.1/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "gitlab_access"
  }
}

resource "aws_instance" "gitlab" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  user_data     = data.local_file.cloud_init_gitlab_yaml.content
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.gitlab.id]

  root_block_device {
    volume_size           = "50"
    delete_on_termination = true
    volume_type           = "gp2"
  }

  tags = {
    Name = "Gitlab"
  }
}