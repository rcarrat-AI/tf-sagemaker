# Configure the AWS provider
provider "aws" {
  region = var.aws_region
}

# Create a VPC if you don't already have one
resource "aws_vpc" "vpc_sagemaker" {
  cidr_block = var.vpc_cidr
}

# Create subnets within the VPC using var.subnet_cidr
resource "aws_subnet" "subnet_sagemaker" {
  count = length(var.subnet_cidr)

  # Use var.subnet_cidr to specify CIDR blocks
  cidr_block = element(var.subnet_cidr, count.index)

  vpc_id = aws_vpc.vpc_sagemaker.id
}

# Create an IAM role for SageMaker Studio
resource "aws_iam_role" "sagemaker_studio_role" {
  name = "sagemaker-studio-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
      }
    ]
  })

  # Attach AmazonSageMakerFullAccess policy and add 'sagemaker:CreateApp' permission
  inline_policy {
    name = "sagemaker-studio-custom-policy"

    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Action = [
            "sagemaker:CreateApp"
          ],
          Effect   = "Allow",
          Resource = "*"
        }
      ]
    })
  }
}

# Attach AmazonSageMakerFullAccess policy to the IAM role
resource "aws_iam_policy_attachment" "sagemaker_studio_policy_attachment" {
  name       = "sagemaker-studio-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
  roles      = [aws_iam_role.sagemaker_studio_role.name]
}

# Create a SageMaker Studio Domain within the VPC and subnets
resource "aws_sagemaker_domain" "studio_domain" {
  domain_name = "studio-domain"
  auth_mode   = "IAM"
  vpc_id      = aws_vpc.vpc_sagemaker.id
  subnet_ids  = aws_subnet.subnet_sagemaker[*].id

  default_user_settings {
    execution_role = aws_iam_role.sagemaker_studio_role.arn
  }
}

# Output the SageMaker Studio Domain ID
output "studio_domain_id" {
  value = aws_sagemaker_domain.studio_domain.id
}
