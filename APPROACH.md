# Architecture and Approach

Hey team, here's a breakdown of the architectural choices and thought process behind the infrastructure and CI/CD setup for this DevOps assignment. I wanted to make sure we stuck to best practices while keeping things maintainable.

## 1. Compute: ECS Fargate
I decided to go with Amazon ECS using the Fargate launch type. 
- **Why not EC2?** Managing EC2 instances (patching, scaling the underlying AMIs) adds a lot of operational overhead. Fargate is serverless compute for containers, so we only worry about the application layer.
- **Scaling:** It's super easy to scale up the number of tasks behind the Application Load Balancer based on traffic.
- **Integration:** It hooks up nicely with CloudWatch for logging out of the box (`awslogs` driver).

## 2. Database: RDS PostgreSQL
The assignment requested PostgreSQL. 
- RDS handles automated backups, patching, and multi-AZ failovers (though I kept it single-AZ `db.t3.micro` for cost reasons during this assignment).
- **Security:** The database is placed in private subnets. The only way to access it is through the ECS security group, keeping it completely isolated from the public internet.

## 3. Infrastructure as Code: Terraform Environments
I split the Terraform code into modules (`vpc`, `security_groups`, `ecs`, `rds`, `cloudwatch`) and isolated configurations using `tfvars` files (`environments/dev.tfvars`, `staging.tfvars`, `prod.tfvars`).
- Modularizing the code makes it way easier to read and reuse. If we ever want to spin up a new environment, we just pass in a new variables file.
- Used an S3 backend with native state locking (`use_lockfile = true`) so state is stored securely and team members don't overwrite each other, without needing an extra DynamoDB table.

## 4. CI/CD Pipeline: GitHub Actions
GitHub actions is pretty much industry standard now for repositories hosted on GitHub.
- **PR Workflow:** Runs `pytest` to make sure we don't break existing functionality. We enforce branch protection so code can't merge to `main` if tests fail.
- **Multi-Stage Deploy Workflow:** Triggers on merge to `main`. It builds the docker image, runs a Trivy vulnerability scan to catch any glaring CVEs, and pushes to a single ECR repository.
- **Manual Approvals:** After deploying the new image to the `staging` ECS cluster, the pipeline pauses. It uses GitHub Actions **Environments** to require a manual approval before rolling out the image to the `production` ECS cluster.

## 5. Twelve-Factor App Compliance
The original `flaskr` app used an `instance/config.py` file to load database secrets. This is generally an anti-pattern for containerized apps.
I refactored the app to pull configuration directly from `os.environ`. The Terraform ECS module injects the RDS endpoint, username, and password into the container at runtime. This keeps secrets out of the codebase completely.
