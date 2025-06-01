# 🛠 Multi-Service Application Deployment Pipeline

## 🚀 Project Overview

This project demonstrates a complete DevOps CI/CD pipeline for a Python-based multi-service application, including:

- Two Flask-based microservices
- Containerization with Docker
- Infrastructure provisioning using Terraform
- CI/CD using GitLab CI
- Deployment to AWS EC2

---
![Architecture](https://github.com/user-attachments/assets/8ccad723-42f7-4638-98e2-77720b19567f)

---
## 📁 Project Structure
```
multi-service-app/
│
├── serviceA/
│   ├── app.py                   # Flask app for Service A
│   ├── Dockerfile               # Dockerfile for Service A
│   ├── requirements.txt         # Python dependencies for Service A
│   └── test_app.py              # Unit tests for Service A
│
├── serviceB/
│   ├── processor.py             # Flask app for Service B
│   ├── Dockerfile               # Dockerfile for Service B
│   ├── requirements.txt         # Python dependencies for Service B
│   └── test_processor.py        # Unit tests for Service B
│
├── terraform/
│   ├── main.tf                  # Terraform config to provision AWS EC2 instances
│   ├── variables.tf             # Terraform variables definition
│   └── outputs.tf               # Terraform outputs for IP addresses, etc.
│
├── .gitlab-ci.yml               # GitLab CI/CD pipeline configuration
├── docker-compose.yml           # Compose file for local dev/testing
└── README.md                   # This documentation file
```
---

## ⚙️ Technologies & Tools Used

- **Python 3.11**, Flask, requests
- **Docker** & **Docker Compose**
- **Terraform** (for EC2 infrastructure)
- **GitLab CI/CD**
- **AWS EC2** for deployment

---
## 📦 Services

### 🧩 Service A: `User Service`
- Stores and retrieves user data.
- Routes:
  - `POST /user` — Create a user.
  - `GET /user/<id>` — Retrieve user info.

### 🔧 Service B: `Processor Service`
- Processes data fetched from Service A.
- Route:
  - `GET /process/<user_id>` — Returns uppercased name for the user from Service A.

---
## 🐳 Containerization

Each service has its own Dockerfile which:

- Installs dependencies (Flask, requests, etc.).
- Copies source code into the container.
- Sets environment variables for dynamic configs (e.g., `SERVICE_A_URL`).
- Defines the default command to run the Flask app.
---
## 🏗️ Docker-compose Architecture Overview
```
                        +--------------------------------------+
                        |       Docker Host / EC2 Instance     |
                        |                                      |
                        |     Docker Network (shared bridge)   |
                        |        +------------------------+    |
                        |        | Container: Service A   |    |
                        |        | Flask API              |    |
                        |        | Exposed: 5000          |    |
                        |        +------------------------+    |
                        |                 ↑                    |
                        |        http://service-a:5000/user    |
                        |          Internal HTTP Request       |
                        |                 ↓                    |
                        |        +------------------------+    |
                        |        | Container: Service B   |    |
                        |        | Flask Processor        |    |
                        |        | Exposed: 5001          |    |
                        |        +------------------------+    |
                        +--------------------------------------+

                                 🔁 Internal API Call:
                  Service B → Service A via `http://service-a:5000/user`


```

## 🖥️ Local Development Setup

### 1. Clone the Repository
```bash
git clone https://gitlab.com/nourmadi17-group/multi-service-app
cd multi-service-app
```

### 2. Run Locally (with Docker-compose)
```bash
docker-compose up --build
```
### 3. Unit Tests
```bash
python -m unittest discover serviceA/
python -m unittest discover serviceB/
```
---
## 🌍 Infrastructure as Code with Terraform

This Terraform script provisions the AWS infrastructure needed to run Service A and Service B:

- **Network Setup:** Creates a VPC, subnet, internet gateway, route table, and security group allowing SSH (port 22) and service ports (5000, 5001).
- **Compute:** Launches two EC2 instances (for Service A and Service B) with Amazon Linux 2 AMI, public IPs, and attached security groups.
- **IAM Roles:** Creates an IAM role and instance profile for EC2 instances to send logs/metrics to CloudWatch.
- **SSH Access:** Configures an SSH key pair for secure access to EC2 instances.
- **User Data:** Runs a `setup.sh` script on instance launch for initial setup (e.g., Docker installation).
- **Outputs:** Provides public IP addresses of both EC2 instances.

### Prerequisites

- Install and configure the [AWS CLI](https://aws.amazon.com/cli/).
- Generate an SSH key pair and provide the public key path to Terraform.
```bash
  ssh-keygen -t rsa -b 4096 -f ~/.ssh/your_key_name
```
- Upload the public key path to the public_key_location Terraform variable.
- The private key will be used by both CI/CD and you to SSH into EC2 instances.

## ⚙️ Usage

1. **Customize variables** in `terraform.tfvars`  
   Update values like CIDR blocks, availability zone, instance type, and public key location.

2. **Initialize Terraform**  
```bash
   terraform init
```
3. **Preview infrastructure changes**
```bash
terraform plan
```
4. **Apply Terraform configuration**
```bash
terraform apply
```
---

## 🧪 CI/CD Pipeline (GitLab)

### 🔄 Pipeline Stages

- **Build** – Docker images for both services.
- **Test** – Runs Python `unittest` for both services.
- **Scan** – Static code analysis using Bandit.
- **Deploy** – SSH into EC2 and runs latest containers.


### 🔧 Stages Details

**Build Stage**  
- Build images from service directories.  
- Authenticate and push to GitLab Registry.

**Test Stage**  
- Install Python dependencies.  
- Run `unittest` for each service.

**Scan Stage**  
- Install Bandit.  
- Scan service code and produce security reports.  
- Allows failures without blocking deployment.

**Deploy Stage**  
- Install SSH client.  
- Add EC2 hosts to known hosts.  
- SSH to each EC2 instance: stop old container, pull new image, run container with proper ports and environment variables.

### 🔁 Branching Strategy & Merge Request Workflow

📌 Branching Model: Git Feature Branch Workflow

We follow a branching model that promotes clean development practices and CI/CD efficiency.

| Branch Name      | Purpose                                                                 |
|------------------|-------------------------------------------------------------------------|
| `main`  | Stable production-ready code. Updated only via approved merge requests. |
| `develop`        | Active development branch. All features and fixes are integrated here.  |
| `feature/*`      | New features or enhancements. Merged into `develop`.                    |
| `fix/*`       | Minor bug fixes. Merged into `develop`.                                |
| `hotfix/*`       | Urgent fixes in production. Merged into both `main` and `develop`.     |


### Branch Types

- **Main Branches**  
  - `main` (production-ready code)  
  - `develop` (integration branch for features)

- **Temporary Branches** (feature, fix, hotfix)  
  - `feature/your-feature-name`  
  - `fix/issue-description`  
  - `hotfix/urgent-fix`

## 🔀 Merge Request Workflow

1. **Create a Branch**
```bash
git checkout -b feature/my-new-feature
```
2. **Commit Code**

- Write clear, concise commit messages  
- Follow naming conventions

3. **Push Branch**

```bash
git push origin feature/my-new-feature
```
4. **Create a Merge Request (MR)**

- Target `develop` branch  
- Assign reviewers  
- Ensure pipeline (build, test, scan) passes  

5. **Code Review**

- At least one approval required  
- Fix comments before merge  

6. **Merge & Cleanup**

- Use **Merge**  
- Delete the source branch  

### ✅ Branch Protection (Recommended)

- `main`: protected — no direct pushes  
- `develop`: protected — only MRs allowed  
- Require passing pipelines before merge  

### 🔐 Environment Variables (GitLab CI/CD)

| Variable Name           | Purpose                                           |
|-------------------------|---------------------------------------------------|
| `SSH_PRIVATE_KEY`       | For SSH login to EC2 (added in GitLab UI) |
| `SERVICE_A_PUBLIC_IP`   | Public IP of EC2 running **Service A**            |
| `SERVICE_B_PUBLIC_IP`   | Public IP of EC2 running **Service B**            |
| `SERVICE_A_PRIVATE_IP`  | Internal/private IP used by **Service B** to reach **Service A** |
| `CI_REGISTRY_*`         | GitLab container registry login credentials       |

### 🚀 Deployment Process

1. **Push changes to `develop`**  
   → GitLab CI/CD pipeline runs:  
   `build → test → scan`

2. **Create a Merge Request**  
   → From `develop` → `main`

3. **Once merged into `main`**  
   → GitLab automatically deploys to EC2:

- **Service A** → EC2-A  
- **Service B** → EC2-B
---
# ✅ Deployment Testing

Once the CI/CD pipeline finishes deploying your services to AWS EC2, follow this guide to verify successful deployment and inter-service communication.

---

### 🔹 1. Check Running Containers on EC2

SSH into each EC2 instance and confirm the containers are running:

```bash
# EC2 Instance A (Service A)
ssh ec2-user@<SERVICE_A_PUBLIC_IP>
docker ps

# EC2 Instance B (Service B)
ssh ec2-user@<SERVICE_B_PUBLIC_IP>
docker ps
```
✅ **Expected Output (on each instance):**

```bash
CONTAINER ID   IMAGE                                  PORTS                  NAMES
xxxxxxxxxxxx   registry.gitlab.com/.../service-a      0.0.0.0:5000->5000/tcp service-a
xxxxxxxxxxxx   registry.gitlab.com/.../service-b      0.0.0.0:5001->5001/tcp service-b
```
🔹 2. Test Service A (User Creation & Retrieval)

```bash
# Create user
curl -X POST http://<SERVICE_A_PUBLIC_IP>:5000/user \
     -H "Content-Type: application/json" \
     -d '{"id": 1, "name": "Alice"}'

# Get user
curl http://<SERVICE_A_PUBLIC_IP>:5000/user/1
```
✅ Expected Response:

```json
{"id": 1, "name": "Alice"}
```
🔹 3. Test Service B (Calling Service A)

```bash
curl http://<SERVICE_B_PUBLIC_IP>:5001/process/1
```
✅ Expected Response:

```json
{"name": "ALICE"}
```
