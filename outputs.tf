output "public_ip" {
  value = aws_eip_association.gitlab_eip_association.public_ip
}