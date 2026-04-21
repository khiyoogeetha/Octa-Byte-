terraform {
  required_version = ">= 1.5.0"

  # Best Practice: Use S3 and DynamoDB for Remote State Control
  # Commended out for easy local execution. Uncomment and provide your bucket names to use remote state.
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "devops-assignment/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.30"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

# =======================================================
# 1. VPC Module (Using local custom module)
# =======================================================
module "vpc" {
  source = "./modules/vpc"

  name = "${var.project_name}-${var.environment}-vpc"
  cidr = var.vpc_cidr

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  # Enable NAT Gateway for private subnets to pull images and updates
  enable_nat_gateway = true
  single_nat_gateway = true # Cost optimization: Use 1 NAT instead of 1 per AZ

  enable_dns_hostnames = true
  enable_dns_support   = true
}

# =======================================================
# 2. Security Groups Module
# =======================================================
module "security" {
  source       = "./modules/security"
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
}

# =======================================================
# 3. Database Module (RDS PostgreSQL)
# =======================================================
module "database" {
  source          = "./modules/database"
  project_name    = var.project_name
  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  db_sg_id        = module.security.rds_sg_id
  db_password     = var.db_password
}

# =======================================================
# 4. Compute Module (ALB, ECR, ECS Fargate)
# =======================================================
module "compute" {
  source          = "./modules/compute"
  project_name    = var.project_name
  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  aws_region      = var.aws_region
  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
  alb_sg_id       = module.security.alb_sg_id
  ecs_sg_id       = module.security.ecs_sg_id

  # Inject dynamic DB connection properties to container environment
  db_endpoint = module.database.db_endpoint
  db_user     = module.database.db_username
  db_password = var.db_password
  db_name     = module.database.db_name
}

# =======================================================
# 5. Monitoring Module (CloudWatch Alarms & Dashboard)
# =======================================================
module "monitoring" {
  source       = "./modules/monitoring"
  project_name = var.project_name
  environment  = var.environment
  depends_on   = [module.compute, module.database]
}

