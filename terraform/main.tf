provider "aws" {
  region = var.aws_region
}

#Configuração do Terraform State
terraform {
  backend "s3" {
    bucket = "terraform-state-soat"
    key    = "lambda-pagamentos/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "terraform-state-soat-locking"
    encrypt        = true
  }
}

## .zip do código
data "archive_file" "code" {
  type        = "zip"
  source_dir  = "../src/code"
  output_path = "../src/code/code.zip"
}

#Security Group Lambda Pagamentos
resource "aws_security_group" "security_group_lambda_pagamentos" {
  name_prefix = "security_group_lambda_pagamentos"
  description = "SG for Lambda Pagamentos"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 8000
    to_port   = 8000
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    infra   = "lambda"
    service = "pagamentos"
    Name    = "security_group_lambda_pagamentos"
  }
}

## Infra lambda fila pagamentos
resource "aws_lambda_function" "lambda_pagamentos" {
  function_name    = "lambda-pagamentos"
  handler          = "lambda.main"
  runtime          = "python3.8"
  filename         = data.archive_file.code.output_path
  source_code_hash = data.archive_file.code.output_base64sha256
  role             = var.lambda_execution_role
  timeout          = 30
  description      = "Lamda para Fila de Pagamentos"

  vpc_config {
    subnet_ids         = [var.subnet_a, var.subnet_b]
    security_group_ids = [aws_security_group.security_group_lambda_pagamentos.id]
  }

  environment {
    variables = {
      "URL_BASE" = var.url_base
      "ENDPOINT_PRODUCAO" = "producao_pedidos"
      "ENDPOINT_PAGAMENTO" = "pagamentos/id_pagamento"
      "PORT"     = "8000"
    }
  }

  tags = {
    infra   = "lambda"
    service = "pagamentos"
  }
}

#Trigger SQS
resource "aws_lambda_event_source_mapping" "pagamentos_sqs_trigger" {
  event_source_arn = var.sqs_arn
  function_name    = aws_lambda_function.lambda_pagamentos.arn
  enabled          = true
  batch_size       = 1
}

#Add ingress rule to ALB
resource "aws_security_group_rule" "ingress_rule_alb" {
  security_group_id        = var.security_group_alb
  type                     = "ingress"
  from_port                = 8000
  to_port                  = 8000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.security_group_lambda_pagamentos.id
}