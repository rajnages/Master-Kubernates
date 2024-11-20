#!/bin/bash

# A script to automate the installation of Kubernetes tools and set up a cluster.

set -e  # Exit immediately if a command exits with a non-zero status.

# --- Logging Functions ---
log_info() {
    echo -e "[INFO] $1"
}

log_error() {
    echo -e "[ERR] $1" >&2
}

# --- Variables ---
AWS_BUCKET="cloud-dev.xyz"
AWS_REGION="us-east-1"
KOPS_STATE_STORE="s3://cloud-dev.xyz-1"
CLUSTER_NAME="cloud-dev.xyz"
DNS_ZONE="cloud-dev.xyz"

log_info "=== Kubernetes Tools and Environment Setup ==="

# --- Prerequisites ---
log_info "Updating system and installing prerequisites..."
if ! sudo apt-get update -y; then
    log_error "Failed to update system."
    exit 1
fi

if ! sudo apt-get install -y curl unzip jq dnsutils; then
    log_error "Failed to install required packages."
    exit 1
fi

# --- Generate SSH Key ---
if [ ! -f ~/.ssh/id_rsa ]; then
    log_info "Generating SSH key..."
    if ! ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -q -N ""; then
        log_error "Failed to generate SSH key."
        exit 1
    fi
    log_info "SSH key generated at ~/.ssh/id_rsa."
else
    log_info "SSH key already exists at ~/.ssh/id_rsa."
fi

# --- Install eksctl ---
log_info "Installing eksctl..."
if ! curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp; then
    log_error "Failed to download eksctl."
    exit 1
fi

if ! sudo mv /tmp/eksctl /usr/local/bin || ! sudo chmod +x /usr/local/bin/eksctl; then
    log_error "Failed to install eksctl."
    exit 1
fi
log_info "eksctl installed successfully."

# --- Install kops ---
log_info "Installing kops..."
LATEST_KOPS_VERSION=$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | jq -r '.tag_name')
if ! curl -LO https://github.com/kubernetes/kops/releases/download/${LATEST_KOPS_VERSION}/kops-linux-amd64; then
    log_error "Failed to download kops."
    exit 1
fi

if ! chmod +x kops-linux-amd64 || ! sudo mv kops-linux-amd64 /usr/local/bin/kops; then
    log_error "Failed to install kops."
    exit 1
fi
log_info "kops installed successfully."

# --- Install kubectl ---
log_info "Installing kubectl..."
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
if ! curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"; then
    log_error "Failed to download kubectl."
    exit 1
fi

if ! chmod +x kubectl || ! sudo mv kubectl /usr/local/bin/kubectl; then
    log_error "Failed to install kubectl."
    exit 1
fi
log_info "kubectl installed successfully."

# --- Install AWS CLI ---
log_info "Installing AWS CLI..."
if ! curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"; then
    log_error "Failed to download AWS CLI."
    exit 1
fi

if ! sudo apt-get install -y unzip || ! unzip -q awscliv2.zip || ! sudo ./aws/install; then
    log_error "Failed to install AWS CLI."
    exit 1
fi
log_info "AWS CLI installed successfully."

# --- Create S3 Bucket ---
log_info "Creating S3 bucket: $AWS_BUCKET..."
if ! aws s3api create-bucket --bucket $AWS_BUCKET --region $AWS_REGION; then
    log_error "Failed to create S3 bucket."
    exit 1
fi

log_info "Enabling versioning on the bucket..."
if ! aws s3api put-bucket-versioning --bucket $AWS_BUCKET --versioning-configuration Status=Enabled; then
    log_error "Failed to enable versioning on S3 bucket."
    exit 1
fi
log_info "S3 bucket $AWS_BUCKET is ready."

# --- Set Environment Variables ---
log_info "Exporting environment variables..."
{
    echo "export NAME=$AWS_BUCKET"
    echo "export AWS_REGION=$AWS_REGION"
    echo "export KOPS_STATE_STORE=$KOPS_STATE_STORE"
    echo "export CLUSTER_NAME=$CLUSTER_NAME"
} >> ~/.bashrc

source ~/.bashrc
log_info "Environment variables exported."

# --- Create Kops Cluster Configuration ---
log_info "Generating Kops cluster configuration and saving to cluster.yaml..."
if ! kops create cluster --name=$CLUSTER_NAME \
    --state=$KOPS_STATE_STORE \
    --zones=us-east-1a,us-east-1b \
    --node-count=2 \
    --control-plane-count=1 \
    --node-size=t3.medium \
    --control-plane-size=t3.medium \
    --control-plane-zones=us-east-1a \
    --control-plane-volume-size=10 \
    --node-volume-size=10 \
    --ssh-public-key=~/.ssh/id_rsa.pub \
    --dns-zone=$DNS_ZONE \
    --dry-run --output yaml > cluster.yaml; then
    log_error "Failed to generate Kops cluster configuration."
    exit 1
fi
log_info "Cluster configuration has been saved to cluster.yaml."

# --- Troubleshooting DNS ---
log_info "Configuring DNS resolution..."
{
    sudo systemctl disable systemd-resolved
    sudo systemctl stop systemd-resolved
    echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" | sudo tee /etc/resolv.conf
    sudo tee /etc/hosts > /dev/null << EOF
127.0.0.1   localhost
127.0.0.1   $(hostname)
EOF
    sudo tee /etc/systemd/resolved.conf > /dev/null << EOF
[Resolve]
DNS=8.8.8.8 8.8.4.4
FallbackDNS=8.8.8.8 8.8.4.4 1.1.1.1
EOF
    sudo systemctl restart systemd-resolved
    sudo systemctl status systemd-resolved
} || {
    log_error "Failed to configure DNS resolution."
    exit 1
}
log_info "DNS resolution configured successfully."

log_info "=== Setup Complete ==="
