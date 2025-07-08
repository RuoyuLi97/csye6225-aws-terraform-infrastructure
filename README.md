# CSYE6225 - AWS Terraform Infrastructure
### Network and Cloud Computing Course Project

## Course Context
This project was developed as part of **CSYE6225 - Network and Cloud Computing** at Northeastern University, demonstrating practical application of Infrastructure as Code principles and AWS cloud services.

## Overview
Terraform Infrastructure as Code for deploying a movie ratings API platform on AWS with two EC2 instances and automated testing capabilities.

## Architecture
- **Web Application**: EC2 instance running Spring Boot movie API (from custom AMI)
- **Database**: Dedicated MySQL EC2 instance with persistent EBS storage (from custom AMI)
- **Deployment**: Automated infrastructure provisioning and configuration

## Infrastructure Components

### EC2 Instances
- **Webapp Instance**: Custom AMI with pre-installed Spring Boot application
- **MySQL Instance**: Custom AMI with pre-configured MySQL database and EBS mounting
- **Instance Types**: t2.micro (free tier eligible)
- **Custom AMIs**: Built using companion Packer repository

### DNS Configuration
- **Route 53**: Commented out for sensitive information

## Deployment Configuration

### GitHub Actions Integration
- **Environment**: `AWS_DEPLOYMENT`
- **Automated Testing**: Infrastructure validation and deployment verification
- **CI/CD Pipeline**: Automated deployment on code changes
- **Workflow**: Configured via `classroom.yaml`

### Required Secrets (GitHub Actions)
```yaml
AWS_ACCESS_KEY_ID: AWS access key for deployment
AWS_SECRET_ACCESS_KEY: AWS secret key for deployment
DATABASE_PASSWORD: MySQL database password
EC2_SSH_KEY: Private SSH key for EC2 instance access
WEBAPP_SECRET_KEY: Application secret key for JWT tokens

### Required Variabls (GitHub Actions)
DATABASE_USERNAME: MySQL database username
MYSQL_AMI_ID: Custom MySQL AMI identifier
WEBAPP_AMI_ID: Custom webapp AMI identifier