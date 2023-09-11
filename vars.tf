variable "availability_zones" {
  type    = list(any)
  default = ["us-east-2a"]
}

variable "aws_region" {
  default = "us-east-2"
}

variable "instance_type" {
  default = "g5.2xlarge"
}

variable "name" {
  default = "sage-tf"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type    = list(any)
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}
