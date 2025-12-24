# 🏗️ Market Financials Lambda Terraform

This repository contains the Terraform Infrastructure as Code (IaC) to provision and manage the AWS resources required for the Market Financials Lambda project. It automates the setup of ECR repositories, Lambda functions, API Gateway with custom authentication, and necessary permissions in the `af-south-1` region.

## ✨ Features

* ☁️ **Complete Infrastructure**: Provisions ECR, Lambda, API Gateway, DynamoDB, and IAM roles.
* 🔐 **Secure Access**: Implements a Custom Lambda Authorizer that validates API keys against a DynamoDB table.
* 🔄 **Automated Deployment**: Includes GitHub Actions for planning, applying, and destroying infrastructure.
* 🐳 **Container Support**: Configures ECR repositories with lifecycle policies to manage image retention.
* 🌐 **HTTP API**: Sets up an API Gateway (HTTP) to expose the Lambda function securely.
* 🪵 **Observability**: Configured CloudWatch logging for API Gateway requests and Lambda executions.

## 🛠 Infrastructure Resources

The Terraform scripts provision the following AWS resources:

* **Amazon ECR**: Two mutable repositories with lifecycle policies to keep only the last 5 images:
    * `market-financials`: For the main application logic.
    * `market-financials-auth`: For the custom authorizer function.
* **AWS Lambda**:
    * `market_financials_function`: The main application deployed from ECR (512MB memory).
    * `market_financials_auth_function`: The custom authorizer deployed from ECR, configured with the DynamoDB table name.
* **Amazon DynamoDB**: A `PAY_PER_REQUEST` table named `MarketFinancialsAuthKeys` (Hash Key: `ApiKey`) to store valid API keys.
* **Amazon API Gateway**: An HTTP API (`MarketFinancialsGW`) with a `prod` stage and auto-deployment enabled.
    * **Route**: `POST /market-financials`.
    * **Auth**: Protected by a Custom Request Authorizer using the `market_financials_auth_function` (Expects `x-api-key` header).
* **CloudWatch Logs**: Log groups with 7-day retention for both Lambda functions and API Gateway access logs.
* **IAM Roles**: Roles and policies allowing the Lambdas to execute, the Authorizer to read from DynamoDB, and API Gateway to invoke them.

## ⚙️ Configuration

### 📥 Inputs (Variables)

| Name | Description | Default |
| :--- | :--- | :--- |
| `region` | AWS Region to deploy resources into. | `af-south-1` |
| `tag` | Project tag used for resource tagging. | `market-financials` |

### 📤 Outputs

After applying the Terraform configuration, the following values are output:

* `repository_url`: The URL of the created Amazon ECR repository (for the main app).
* `api_endpoint`: The endpoint of the HTTP API Gateway.
* `base_url`: The invoke URL for the `prod` stage.

## 🔄 CI/CD Workflow

This project uses a manual GitHub Actions workflow (`workflow_dispatch`) to manage the infrastructure state.

### Triggering the Workflow
When running the workflow manually, you must select the job to run via the `job_to_run` input:

1.  **terraform-apply**: Runs `terraform plan` followed by `terraform apply` to provision or update resources.
2.  **terraform-destroy-apply**: Runs `terraform plan -destroy` followed by `terraform destroy` to tear down all resources.

### Jobs
* **Terraform Plan**: Validates code and generates an execution plan.
* **Terraform Apply**: Applies the changes to the `production` environment (auto-approved).
* **Terraform Destroy Plan/Apply**: Handles the safe destruction of infrastructure when selected.

The pipeline uses an S3 backend (`market-financials-lambda-terrafom-state`) to store the Terraform state file securely.

## 🔨Tools used:
[![My Skills](https://skillicons.dev/icons?i=aws,terraform,git,githubactions&perline=6)](https://skillicons.dev)
