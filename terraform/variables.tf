variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "lambda_execution_role" {
  description = "Execution Role Lambda"
  type        = string
  sensitive   = true
  default     = ""
}

variable "vpc_id" {
  type    = string
  default = "vpc-02704242632eb2597"
}

variable "subnet_a" {
  type    = string
  default = "subnet-0c485509fe2864438"
}

variable "subnet_b" {
  type    = string
  default = "subnet-000064d84790b3f77"
}

variable "url_base" {
  type      = string
  sensitive = true
  default   = ""
}

variable "sqs_arn" {
  type      = string
  sensitive = true
  default   = ""
}

variable "security_group_alb" {
  type      = string
  sensitive = true
  default   = ""
}
