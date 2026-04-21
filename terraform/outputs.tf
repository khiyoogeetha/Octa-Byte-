output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "db_endpoint" {
  description = "PostgreSQL DB endpoint"
  value       = module.database.db_endpoint
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name (Use this to access the app)"
  value       = module.compute.alb_dns_name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.compute.ecr_repository_url
}
