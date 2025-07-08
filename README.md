# CSYE6225 - AWS Terraform Infrastructure
### Network and Cloud Computing Course Project

## Course Context
This project was developed as part of **CSYE6225 - Network and Cloud Computing** at Northeastern University, demonstrating practical application of Infrastructure as Code principles, load balancing, and automated deployment workflows.

## Overview
Terraform Infrastructure as Code for deploying a scalable movie ratings API platform on AWS with Network Load Balancer, automated testing, and comprehensive security configuration.

## Architecture
- **Load Balancer**: AWS Network Load Balancer distributing traffic across 3 webapp instances
- **Web Application**: 3 EC2 instances running Spring Boot movie API (custom AMI)
- **Database**: MySQL EC2 instance with persistent EBS volume in private subnet (custom AMI)
- **Networking**: VPC with public/private subnets, security groups, and least privilege access
- **Monitoring**: CloudWatch integration with custom metrics and dashboards (configured in AMIs)
- **Automation**: Complete infrastructure provisioning with Java-based integration testing

## Infrastructure Components

### Networking & Security
- **VPC**: Custom Virtual Private Cloud with DNS support and Internet Gateway
- **Subnets**: Public subnet for webapps/NLB, private subnet for MySQL isolation
- **Security Groups**: Multi-layered security with granular port access control
- **Load Balancer**: TCP load balancing with HTTP health checks on `/v1/healthcheck`

### Compute, Storage & Monitoring
- **EC2 Instances**: 3 webapp instances + 1 MySQL instance (t2.micro)
- **Custom AMIs**: Pre-configured with Spring Boot application and MySQL database
- **EBS Volume**: Persistent storage with automated attachment and configuration
- **CloudWatch Monitoring**: System metrics (CPU, memory, disk, network) with 1-minute resolution
- **SSH Access**: Dynamic RSA 4096-bit key pair generation and secure distribution

## Deployment Configuration

### GitHub Actions Workflows
- **classroom.yaml**: Main deployment workflow with manual trigger and autograding
- **integration_tests.yaml**: Dedicated integration testing workflow
- **Environment**: `AWS_DEPLOYMENT` with secure secrets management

### Required Secrets & Variables
```yaml
# Secrets (must be configured in GitHub repository settings)
AWS_ACCESS_KEY_ID: Valid AWS access key for deployment
AWS_SECRET_ACCESS_KEY: Valid AWS secret key for deployment  
DATABASE_PASSWORD: MySQL database password
EC2_SSH_KEY: Private SSH key for EC2 instance access
WEBAPP_SECRET_KEY: Application secret key for JWT tokens

# Variables (must be configured in GitHub repository settings)
DATABASE_USERNAME: MySQL database username
MYSQL_AMI_ID: Valid custom MySQL AMI identifier
WEBAPP_AMI_ID: Valid custom webapp AMI identifier
```

**⚠️ Important Note**: All secrets and variables in this repository contain placeholder/invalid values for security purposes. To run this infrastructure, you must:
1. Configure valid AWS credentials with appropriate permissions
2. Build custom AMIs using the companion [Packer repository](https://github.com/RuoyuLi97/csye6225-aws-movie-api-ami-builder)
3. Update all GitHub repository secrets and variables with actual values
4. Ensure AWS account has sufficient permissions for VPC, EC2, and Load Balancer operations

## File Structure
```
├── main.tf                          # Complete infrastructure configuration
├── variables.tf                     # Variable definitions
├── outputs.tf                       # Output configurations
├── pom.xml                          # Maven configuration for integration tests
├── .github/workflows/               # GitHub Actions workflows
│   ├── classroom.yaml               # Autograding and deployment workflow
│   └── integration_tests.yaml       # Integration testing workflow
├── scripts/                         # Deployment automation scripts
│   ├── setup_webapp.sh              # Webapp initialization script
│   ├── setup_mysql_ebs.sh           # EBS volume setup script
│   ├── update_mysql_bind_address.sh # MySQL network configuration
│   └── setup_database.sh            # Database initialization script
├── src/test/java/com/example/       # Java integration test suite
│   ├── HealthCheckTest.java         # Health check endpoint tests
│   ├── LinkTest.java                # Link API endpoint tests
│   ├── LoginTest.java               # User authentication tests
│   ├── MovieTest.java               # Movie API endpoint tests
│   ├── RegisterTest.java            # User registration tests
│   └── TestApplication.java         # Test application configuration
└── terraform.tfvars                 # Generated during deployment
```

## Integration Testing
Comprehensive Java-based test suite using Maven that validates:
- **API Endpoints**: Health check, user registration/login, movie/rating/link APIs
- **Load Balancer**: Traffic distribution and health checking across instances
- **Database Connectivity**: MySQL connection and data persistence
- **Security**: Authentication and authorization workflows

Tests run against live infrastructure with dynamically configured base URLs.

## Deployment Instructions

### Automated Deployment (Recommended)
**Prerequisites**: 
- Valid AWS credentials configured in GitHub secrets
- Custom AMIs built using companion Packer repository
- All repository secrets and variables updated with actual values (current values are placeholders)

Steps:
1. Configure GitHub repository secrets and variables with valid values
2. Trigger workflow via GitHub Actions "Run workflow" button
3. Infrastructure automatically validates, provisions, and tests

### Manual Deployment
```bash
terraform init
terraform plan
terraform apply -auto-approve
# terraform destroy -auto-approve  # For cleanup
```

## Performance & Security
- **Load Balancing**: Supports 1,790+ queries/minute across 3 instances
- **High Availability**: Health-checked instances with automatic failover
- **Security**: Database isolation in private subnet, granular security groups
- **Automation**: End-to-end infrastructure provisioning with zero manual configuration

## Related Repositories
- **AMI Builder**: [csye6225-aws-movie-api-ami-builder](https://github.com/RuoyuLi97/csye6225-aws-movie-api-ami-builder)

## Tech Stack
Terraform | AWS | EC2 | NLB | VPC | CloudWatch | GitHub Actions | Java | Maven