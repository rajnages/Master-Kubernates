#!/bin/bash

#IAM ROLE AND ASSIGN IT TO EC2 
#CREATE A EC2 INSTANCE AND GENERATE SSH ROLE
#download Kops and Kubectl to usr/local/bin and change permissions.


curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
sudo chmod +x /usr/local/bin/eksctl

#install kops
curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
chmod +x kops-linux-amd64
sudo mv kops-linux-amd64 /usr/local/bin/kops

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

#install aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt-get install unzip
unzip awscliv2.zip
sudo ./aws/install

aws s3api create-bucket \
    --bucket cloud-dev.xyz \
    --region us-east-1

# Enable bucket versioning
aws s3api put-bucket-versioning \
    --bucket cloud-dev.xyz \
    --versioning-configuration Status=Enabled

#export variables
export NAME=cloud-dev.xyz
export AWS_REGION=us-east-1
export KOPS_STATE_STORE=s3://cloud-dev.xyz
export CLUSTER_NAME=cloud-dev.xyz

source ~/.bashrc

#create cluster using kops we need domain name
# kops create cluster \
#     --name=${NAME} \
#     --cloud=aws \
#     --zones=us-east-1a,us-east-1b \
#     --master-size=t3.medium \
#     --node-size=t3.medium \
#     --node-count=2 \
#     --networking=calico \
#     --ssh-public-key=~/.ssh/id_rsa.pub \
#     --dry-run \
#     --output yaml > cluster-config.yaml

# # Smoke test commands after cluster creation
# kops create -f cluster.yaml
# kops update cluster --name cloud-dev.xyz --yes --admin
# kops validate cluster --wait 10m
# kops cluster info
# kops delete -f cluster.yml  --yes

# #create eks cluster using eksctl
# eksctl create cluster --name=eksdemo \
#                      --region=us-east-1 \
#                      --zones=us-east-1a,us-east-1b \
#                      --nodegroup-name=eksdemo-ng \
#                      --node-type=t3.medium \
#                      --nodes=2 \
#                      --nodes-min=2 \
#                      --nodes-max=4 \
#                      --node-volume-size=20 \
#                      --ssh-access \
#                      --ssh-public-key=Manage-Key \
#                      --managed \
#                      --asg-access \
#                      --external-dns-access \
#                      --full-ecr-access \
#                      --appmesh-access \
#                      --alb-ingress-access

# # Get List of clusters
# eksctl get cluster                  

# # Smoke test commands after cluster creation
# kubectl get nodes -o wide
# kubectl get pods --all-namespaces
# kubectl cluster-info
# kubectl get svc
# eksctl get cluster --name eksdemo --region us-east-1
               

# kops create cluster \
#   --name=cloud-dev.xyz \
#   --state=s3://cloud-dev.xyz \
#   --zones=us-east-1a,us-east-1b \
#   --node-count=2 \
#   --control-plane-count=1 \           
#   --node-size=t3.medium \
#   --control-plane-size=t3.medium \    
#   --control-plane-zones=us-east-1a \  
#   --control-plane-volume-size=10 \    
#   --node-volume-size=10 \
#   --ssh-public-key=~/.ssh/id_ed25519.pub \
#   --dns-zone=cloud-dev.xyz \
#   --dry-run \
#   --output yaml > cluster-config.yaml


kops create cluster --name=cloud-dev.xyz \
--state=s3://cloud-dev.xyz --zones=us-east-1a,us-east-1b \
--node-count=2 --control-plane-count=1 --node-size=t3.medium --control-plane-size=t3.medium \
--control-plane-zones=us-east-1a --control-plane-volume-size 10 --node-volume-size 10 \
--ssh-public-key ~/.ssh/id_rsa.pub \
--dns-zone=cloud-dev.xyz --dry-run --output yaml



# Get instance profile name for a specific EC2 instance
# aws ec2 describe-instances \
#     --instance-id i-0cb41d8cea0d15f7a \
#     --query 'Reservations[*].Instances[*].IamInstanceProfile.Arn' \
#     --output text

# # Get role details from instance profile
# aws iam list-instance-profiles \
#     --query 'InstanceProfiles[*].[InstanceProfileName,Roles[0].RoleName]' \
#     --output table

# # List policies attached to a role
# aws iam list-attached-role-policies \
#     --role-name kops-role

# # Get inline policies
# aws iam list-role-policies \
#     --role-name YOUR_ROLE_NAME

       
####troubleshooting issues commands
dig cloud-dev.xyz
sudo vi /etc/resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4

sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved

sudo vi /etc/hosts
127.0.0.1   localhost
127.0.0.1   ip-172-31-95-17

sudo vi /etc/systemd/resolved.conf
[Resolve]
DNS=8.8.8.8 8.8.4.4
FallbackDNS=8.8.8.8 8.8.4.4 1.1.1.1


# whois cloud-dev.xyz
# dig cloud-dev.xyz NS
# dig @1.1.1.1 cloud-dev.xyz NS

sudo systemctl restart systemd-resolved
sudo systemctl status systemd-resolved