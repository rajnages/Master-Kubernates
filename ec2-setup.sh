#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Variables
KEY_NAME="MyUbuntuKeyPair"
ROLE_NAME="MyAdminRole"
INSTANCE_TYPE="t2.micro"
REGION="us-east-1"  # Change to your desired region
TRUST_POLICY_FILE="trust-policy.json"

# Function to log messages
log() {
    echo "[INFO] $(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Function to handle errors
error_exit() {
    echo "[ERROR] $(date +'%Y-%m-%d %H:%M:%S') - $1" >&2
    exit 1
}

# Create the trust policy file
log "Creating trust policy file..."
cat <<EOL > $TRUST_POLICY_FILE
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOL

# Fetch the latest Ubuntu AMI ID
log "Fetching the latest Ubuntu AMI ID..."
AMI_ID=$(aws ec2 describe-images --owners 099720109477 \
    --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*" \
    --query "Images[0].ImageId" --output text --region $REGION)

if [ -z "$AMI_ID" ]; then
    error_exit "Unable to find the latest Ubuntu AMI ID."
fi

log "Using Ubuntu AMI ID: $AMI_ID"

# Check if the key pair already exists
if ! aws ec2 describe-key-pairs --key-names $KEY_NAME > /dev/null 2>&1; then
    log "Creating key pair..."
    aws ec2 create-key-pair --key-name $KEY_NAME --query 'KeyMaterial' --output text > $KEY_NAME.pem
    chmod 400 $KEY_NAME.pem
    log "Key pair created and saved to $KEY_NAME.pem"
else
    log "Key pair $KEY_NAME already exists."
fi

# Create IAM role if it doesn't exist
if ! aws iam get-role --role-name $ROLE_NAME > /dev/null 2>&1; then
    log "Creating IAM role..."
    aws iam create-role --role-name $ROLE_NAME --assume-role-policy-document file://$TRUST_POLICY_FILE
    aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
    log "IAM role $ROLE_NAME created and AdministratorAccess policy attached."
else
    log "IAM role $ROLE_NAME already exists."
fi

# Create an instance profile for the IAM role
INSTANCE_PROFILE_NAME="${ROLE_NAME}Profile"
if ! aws iam get-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME > /dev/null 2>&1; then
    log "Creating instance profile..."
    aws iam create-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME
    aws iam add-role-to-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME --role-name $ROLE_NAME
    log "Instance profile $INSTANCE_PROFILE_NAME created and role $ROLE_NAME added."
else
    log "Instance profile $INSTANCE_PROFILE_NAME already exists."
fi

# Get the default subnet ID
SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=default-for-az,Values=true" --query "Subnets[0].SubnetId" --output text)
log "Using default subnet ID: $SUBNET_ID"

# Get the default security group ID
SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=default" --query "SecurityGroups[0].GroupId" --output text)
log "Using default security group ID: $SECURITY_GROUP_ID"

# Create the EC2 instance
log "Creating EC2 instance..."
INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID \
    --count 1 \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME \
    --iam-instance-profile Name=$INSTANCE_PROFILE_NAME \
    --subnet-id $SUBNET_ID \
    --security-group-ids $SECURITY_GROUP_ID \
    --query 'Instances[0].InstanceId' \
    --output text)

log "EC2 instance created with ID: $INSTANCE_ID"

# Output the public IP address of the instance
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
log "You can access your instance at: http://$PUBLIC_IP"

# Clean up the trust policy file
rm -f $TRUST_POLICY_FILE
log "Cleaned up the trust policy file."