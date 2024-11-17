# eks
Amazon Elastic Container Service for Kubernetes (EKS) is a managed container service that makes it easy to deploy, manage, and scale containerized applications using Kubernetes on AWS.

Key Features:

- Managed Kubernetes service
- Highly available and durable clusters
- Integrated with AWS services (such as ELB, EBS, and IAM)
- Pay only for what you use
- Supports both Linux and Windows workloads
- Automatic security patches and updates
- Supports Kubernetes Network Policies
- Supports Kubernetes Service Mesh (Istio)

Components:

- **Control Plane**: The control plane consists of the Kubernetes API server and etcd. It is responsible for maintaining the desired state of the cluster and scheduling workloads.
- **Data Plane**: The data plane consists of the worker nodes that run the containers. It is responsible for executing the workloads scheduled by the control plane.

Use Cases:

- **Web Applications**: Run web applications on EKS using Kubernetes deployments and services.
- **Microservices**: Run microservices on EKS using Kubernetes deployments, services, and ingress resources.
- **Big Data**: Run big data workloads on EKS using Kubernetes jobs and cron jobs.
- **Machine Learning**: Run machine learning workloads on EKS using Kubernetes jobs and services.
