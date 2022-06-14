output "user_private_key_pem" {
  description = "Private key in PEM format."
  value       = nonsensitive(tls_private_key.rsa-4096.private_key_pem)
}

output "public_ip" {
  description = "The public ip of the web server."
  value       = aws_instance.paul-web-tf.public_ip
}

output "certificate_pem" {
  value = acme_certificate.certificate.certificate_pem
}

output "issuer_pem" {
  value = acme_certificate.certificate.issuer_pem
}

output "cert_private_key_pem" {
  value = nonsensitive(acme_certificate.certificate.private_key_pem)
}
