terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

resource "null_resource" "lab_ready" {
  provisioner "local-exec" {
    command = "echo Local platform lab ready"
  }
}

variable "environment" {
  type    = string
  default = "local"
}

output "status" {
  value = "Local lab initialized"
}
