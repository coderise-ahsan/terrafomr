provider "aws" {
  region     = "us-east-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "learnfromexperts-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "ec2-instance" {
  source                 = "terraform-aws-modules/ec2-instance/aws"

  name                   = "web-cluster"
  instance_count         = 2

  ami                    = "ami-009d6802948d06e52"
  instance_type          = "t2.micro"
  key_name               = "lfe-key-pair"
  monitoring             = true
  vpc_security_group_ids = ["sg-035d5dd9b3188a49b"]
  associate_public_ip_address = true
  subnet_id              = "subnet-09b994ffe2d344abc"

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "elb_http" {
  source = "terraform-aws-modules/elb/aws"

  name = "lfe-webcluster"

  subnets         = ["subnet-09b994ffe2d344abc", "subnet-0273f85c7c896fdfe", "subnet-048c0a6ec74dbd2ba"]
  security_groups = ["sg-035d5dd9b3188a49b"]
  internal        = false

  listener = [
    {
      instance_port     = "80"
      instance_protocol = "HTTP"
      lb_port           = "80"
      lb_protocol       = "HTTP"
    },
  ]

  health_check = [
    {
      target              = "HTTP:80/"
      interval            = 30
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 5
    },
  ]

  number_of_instances = 2
  instances           = ["i-0fc8b8cbf0ecc3e6a", "i-0a8c588e58079ea10"]

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}

