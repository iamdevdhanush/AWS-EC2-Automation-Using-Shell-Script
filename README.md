# 🚀 AWS EC2 Automation Using Shell Script

This project demonstrates **automated EC2 instance provisioning on AWS using Bash and AWS CLI**.  
It is designed for **DevOps beginners / freshers** to understand real-world AWS automation, IAM usage, and region-aware infrastructure provisioning.

The script validates inputs, installs dependencies, checks authentication, and safely launches an EC2 instance with proper logging.

---

## 📌 What This Project Does

- Installs required dependencies (`awscli`, `jq`) automatically
- Verifies AWS CLI authentication
- Validates mandatory inputs before execution
- Launches an EC2 instance using AWS CLI
- Waits until the instance reaches **running** state
- Adds meaningful tags (Name, Project, Owner, Environment)
- Uses **region-safe**, **idempotent**, and **production-style** scripting practices
- Logs execution steps to a log file

---

## 🛠️ Technologies Used

- **Bash / Shell Scripting**
- **AWS EC2**
- **AWS CLI v2**
- **IAM (Users, Policies, Access Keys)**
- **Linux (Ubuntu)**

---

## 📂 Project Structure

```
.
├── ec2_provision.sh      # Main automation script
├── ec2.env               # Environment variables (NOT committed)
├── ec2_provision.log     # Execution logs
└── README.md
```

---

## ⚠️ Security & Best Practices

- ❌ **No AWS credentials are hardcoded**
- ❌ **No passwords or secrets are committed**
- ✅ Uses environment variables for sensitive data
- ✅ `.env` file should be added to `.gitignore`

**NEVER commit the following:**
- AWS Access Key
- AWS Secret Key
- `.pem` private key files
- `ec2.env`

---

## 🔐 Prerequisites

Before running the script, ensure:

1. You have an **AWS account**
2. An **IAM user** with EC2 permissions (e.g. `AmazonEC2FullAccess`)
3. AWS CLI installed **or** allow the script to install it
4. AWS CLI configured:
   ```bash
   aws configure
   ```
5. A key pair created in the same AWS region
6. Basic knowledge of Linux terminal

---

## 🌍 Region Used

This project was tested with:
```
ap-south-1 (Asia Pacific - Mumbai)
```

⚠️ **All AWS resources (AMI, subnet, security group, key pair) must belong to the SAME region.**

---

## ⚙️ Configuration (Required)

Create an environment file:

```bash
nano ec2.env
```

Add the following (example):

```bash
AMI_ID=ami-xxxxxxxxxxxxxxxxx
KEY_NAME=devops-key
SUBNET_ID=subnet-xxxxxxxxxxxx
SECURITY_GROUP_IDS=sg-xxxxxxxxxxxx
INSTANCE_TYPE=t3.micro
```

> Replace values with **real IDs from your AWS account**.

---

## ▶️ How to Run

Load variables and execute:

```bash
set -a
source ec2.env
set +a

./ec2_provision.sh
```

---

## 📜 Sample Output

```text
Launching EC2 instance...
EC2 instance created: i-0xxxxxxxxxxxx
Waiting for EC2 instance to reach running state...
Instance i-0xxxxxxxxxxxx is running
EC2 provisioning completed successfully
```

---

## 🧾 Logging

All execution logs are saved to:

```
ec2_provision.log
```

Useful for debugging and audit trails.

---

## 💸 Cost Warning (IMPORTANT)

- EC2 instances **cost money**
- Free Tier has limits
- Always **stop or terminate** instances after testing

Recommended:
```
EC2 → Instances → Stop / Terminate
```

---

## 🧠 What You Learn From This Project

- IAM authentication vs authorization
- AWS region-specific resources
- EC2 automation using CLI
- Handling real AWS errors
- Writing safe shell scripts with `set -euo pipefail`
- Environment-based configuration
- Production-style validation and logging

---

## 📈 Improvements You Can Add

- Auto-terminate instance after X hours
- Dry-run mode
- Support for multiple regions
- Terraform version of the same logic
- CI/CD integration (GitHub Actions)

---

## 👨‍💻 Author

**Dhanu**  
DevOps & Cloud Enthusiast  
GitHub: https://github.com/iamdevdhanush

---

## ⭐ Final Note

This project focuses on **real DevOps behavior**, not click-ops.  
If you understand and can explain this script, you are already ahead of many beginners.

Feel free to fork, improve, and contribute.

