# 🏗️ Market Financials Lambda Terraform

This repository contains the Terraform Infrastructure as Code (IaC) to provision and manage the AWS resources required for the Market Financials Lambda project. It automates the setup of the ECR repository, Lambda function, API Gateway, and necessary permissions in the `af-south-1` region.

## ✨ Features

* ☁️ **Complete Infrastructure**: Provisions ECR, Lambda, API Gateway, and IAM roles.
* 🔄 **Automated Deployment**: Includes GitHub Actions for planning, applying, and destroying infrastructure.
* 🐳 **Container Support**: Configures an ECR repository with lifecycle policies to manage image retention.
* 🌐 **HTTP API**: Sets up an API Gateway (HTTP) to expose the Lambda function.
* 🪵 **Observability**: Configured CloudWatch logging for API Gateway requests.

## 🛠 Infrastructure Resources

The Terraform scripts provision the following AWS resources:

* **Amazon ECR**: A mutable repository named `market-financials` with a lifecycle policy to keep only the last 5 images.
* **AWS Lambda**: A function named `market_financials_function` deployed from the ECR image, with 512MB memory and a 30-second timeout.
* **Amazon API Gateway**: An HTTP API (`market_financials_gw`) with a `prod` stage and auto-deployment enabled.
    * **Route**: `GET /market-financials`.
* **CloudWatch Logs**: A log group with 7-day retention for API Gateway access logs.
* **IAM Roles**: Roles and policies allowing the Lambda to execute and API Gateway to invoke it.

## ⚙️ Configuration

### 📥 Inputs (Variables)

| Name | Description | Default |
| :--- | :--- | :--- |
| `region` | AWS Region to deploy resources into. | `af-south-1` |
| `tag` | Project tag used for resource tagging. | `market-financials` |

### 📤 Outputs

After applying the Terraform configuration, the following values are output:

* `repository_url`: The URL of the created Amazon ECR repository.
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
