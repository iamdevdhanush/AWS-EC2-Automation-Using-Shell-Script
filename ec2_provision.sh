#!/bin/bash
set -euo pipefail

LOG_FILE="ec2_provision.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $1" | tee -a "$LOG_FILE"
}

error_exit() {
    echo "ERROR: $1" >&2
    exit 1
}

detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
    else
        error_exit "Cannot detect operating system"
    fi

    if [[ "$OS" != "ubuntu" && "$OS" != "debian" ]]; then
        error_exit "Unsupported OS: $OS (only Ubuntu/Debian supported)"
    fi
}

install_dependencies() {
    log "Installing dependencies (awscli, jq)..."

    sudo apt update -y
    sudo apt install -y curl unzip jq

    if ! command -v aws >/dev/null; then
        log "AWS CLI not found. Installing AWS CLI v2..."

        curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
        unzip -q awscliv2.zip
        sudo ./aws/install
        rm -rf aws awscliv2.zip

        log "AWS CLI installed successfully"
    fi
}

check_aws_auth() {
    aws sts get-caller-identity >/dev/null \
        || error_exit "AWS credentials not configured. Run 'aws configure'"
validate_inputs() {
    if [[ -z "$AMI_ID" ]]; then
        error_exit "AMI_ID is required"
    fi

    if [[ -z "$KEY_NAME" ]]; then
        error_exit "KEY_NAME is required"
    fi

    if [[ -z "$SUBNET_ID" ]]; then
        error_exit "SUBNET_ID is required"
    fi

    if [[ -z "$SECURITY_GROUP_IDS" ]]; then
        error_exit "SECURITY_GROUP_IDS is required"
    fi
}
}

validate_inputs() {
    [[ -z "$AMI_ID" ]] && error_exit "AMI_ID is required"
    [[ -z "$KEY_NAME" ]] && error_exit "KEY_NAME is required"
    [[ -z "$SUBNET_ID" ]] && error_exit "SUBNET_ID is required"
    [[ -z "$SECURITY_GROUP_IDS" ]] && error_exit "SECURITY_GROUP_IDS is required"
}

wait_for_instance() {
    local id="$1"
    log "Waiting for EC2 instance $id to reach running state..."

    aws ec2 wait instance-running \
        --instance-ids "$id" \
        --region "$AWS_REGION"

    log "Instance $id is running"
}

create_ec2_instance() {
    log "Launching EC2 instance..."

    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id "$AMI_ID" \
        --instance-type "$INSTANCE_TYPE" \
        --key-name "$KEY_NAME" \
        --subnet-id "$SUBNET_ID" \
        --security-group-ids $SECURITY_GROUP_IDS \
        --region "$AWS_REGION" \
        --tag-specifications "ResourceType=instance,Tags=[
            {Key=Name,Value=$INSTANCE_NAME},
            {Key=Environment,Value=$ENVIRONMENT},
            {Key=Owner,Value=$OWNER},
            {Key=Project,Value=$PROJECT}
        ]" \
        --query 'Instances[0].InstanceId' \
        --output text)

    [[ -z "$INSTANCE_ID" ]] && error_exit "EC2 instance creation failed"

    log "EC2 instance created: $INSTANCE_ID"
    wait_for_instance "$INSTANCE_ID"
}

# ------------------ MAIN ------------------
AWS_REGION="${AWS_REGION:-ap-south-1}"
AMI_ID="${AMI_ID:-}"
INSTANCE_TYPE="${INSTANCE_TYPE:-t2.micro}"
KEY_NAME="${KEY_NAME:-}"
SUBNET_ID="${SUBNET_ID:-}"
SECURITY_GROUP_IDS="${SECURITY_GROUP_IDS:-}"
AWS_REGION="${AWS_REGION:-ap-south-1}"

INSTANCE_NAME="${INSTANCE_NAME:-Shell-Automated-EC2}"
ENVIRONMENT="${ENVIRONMENT:-dev}"
OWNER="${OWNER:-dhanu}"
PROJECT="${PROJECT:-aws-shell-automation}"

detect_os
install_dependencies
check_aws_auth
validate_inputs
create_ec2_instance

log "EC2 provisioning completed successfully"

