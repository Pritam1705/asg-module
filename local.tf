# security group

locals {
  sg_name = "${var.environment}-${var.application_name}-sg"
}