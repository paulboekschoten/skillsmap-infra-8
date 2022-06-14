locals {
  any_port      = 0
  any_icmp_port = -1
  any_protocol  = "-1"
  tcp_protocol  = "tcp"
  icmp_protocol = "icmp"
  all_ips       = ["0.0.0.0/0"]
}

variable "http_port" {
  description = "Server port for HTTP requests."
  type        = number
  default     = 80
}

variable "https_port" {
  description = "Server port for HTTPS requests."
  type        = number
  default     = 443
}

variable "ssh_port" {
  description = "Server port for SSH requests."
  type        = number
  default     = 22
}