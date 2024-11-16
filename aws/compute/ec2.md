# Compute Services
## EC2
Virtual servers in the cloud that provide resizable compute capacity
Use cases:
- Web application hosting and serving
- Development/test environments
- Gaming servers
- Batch processing workloads
- High-performance computing
- Enterprise applications

Key features:
- Choose from various instance types optimized for different use cases
- Multiple purchasing options (On-Demand, Reserved, Spot instances)
- Integrated with VPC for networking security
- Elastic Block Storage (EBS) for persistent storage
- Auto Scaling to dynamically adjust capacity
- Load balancing support
- Rich monitoring via CloudWatch

Why choose EC2:
- Complete control over computing resources
- Flexible configuration options for CPU, memory, storage and networking
- Pay only for what you use with per-second billing
- Quickly scale up/down based on demand
- Wide selection of operating systems and software packages
- Supports both Windows and Linux workloads

## Auto Scaling
Automatically adjusts compute capacity to maintain application availability

Key benefits:
- Better fault tolerance by automatically replacing unhealthy instances
- Improved application availability by maintaining desired capacity
- Cost optimization by dynamically adjusting resources based on demand
- Seamless scaling across Availability Zones
- Automatic integration with Elastic Load Balancing

Use cases:
- Web applications with variable traffic patterns
- Batch processing and analytics workloads  
- Microservices architectures
- Gaming and streaming applications
- CI/CD environments

Why choose Auto Scaling:
- Eliminates manual capacity planning and scaling
- Reduces operational overhead through automation
- Optimizes costs by matching capacity to actual demand
- Improves application resilience and reliability
- Supports predictive and dynamic scaling policies
- Integrates with CloudWatch for metrics-based scaling

Types of Auto Scaling:

1. Target Tracking Scaling
- Automatically adjusts capacity based on a target metric value
- Example: Maintain average CPU utilization at 70%
- Best for applications with predictable load patterns

2. Step Scaling
- Scales based on CloudWatch alarms with multiple step adjustments
- Allows more granular control over scaling responses
- Good for applications needing precise scaling thresholds

## EBS Volumes
Provides block-level storage volumes for EC2 instances

Key benefits:
- Persistent storage that exists independently of EC2 instances
- Automatically replicated within Availability Zone
- Easy to backup via snapshots
- Encryption available for data at rest
- Flexible volume types for different workloads
- Can be detached/reattached between instances

Volume Types:

1. General Purpose SSD (gp2/gp3)
- Balance of price and performance
- Suitable for boot volumes, dev/test environments
- Good for most workloads
- gp3 offers predictable performance and lower cost

2. Provisioned IOPS SSD (io1/io2)
- Highest performance SSD volume
- Mission-critical low-latency workloads
- Large database workloads
- Applications needing sustained IOPS performance

3. Throughput Optimized HDD (st1)
- Low-cost HDD volume
- Frequently accessed, throughput-intensive workloads
- Big data, data warehouses, log processing
- Cannot be boot volume

4. Cold HDD (sc1)
- Lowest cost HDD volume
- Less frequently accessed workloads
- Large volumes of cold data
- Cannot be boot volume

Why choose specific volume types:
- General Purpose 2 (gp2)/General Purpose 3 (gp3): Most workloads requiring balance of price/performance
- Provisioned IOPS SSD (io1/io2): Databases and latency-sensitive applications
- Throughput Optimized HDD (st1): Big data and sequential processing
- Cold HDD (sc1): Infrequently accessed data requiring lowest storage cost

# different storage types
# ebs is the block storage for ec2 instances
# s3 is the object storage for the web
# efs is the network file storage for linux

## Load Balancers
Distributes incoming application traffic across multiple targets like EC2 instances

Key Benefits:
- High availability and fault tolerance
- Automatic scaling of applications
- Health checks and self-healing
- SSL/TLS termination
- Session stickiness
- Zone redundancy
- Centralized security management

Types of Load Balancers:

1. Application Load Balancer (ALB)
- Layer 7 (HTTP/HTTPS) load balancing - operates at the application layer of the OSI model, allowing content-based routing by inspecting HTTP headers, URLs, and application data
- Advanced request routing based on content
- Support for WebSocket and HTTP/2
- Container and microservices friendly
- Path-based routing
- Host-based routing
- Support for Lambda functions as targets

2. Network Load Balancer (NLB) 
- Layer 4 (TCP/UDP) load balancing
- Ultra-high performance and low latency
- Handles millions of requests per second
- Static IP support
- Preserves source IP address
- Ideal for TCP/UDP traffic

3. Classic Load Balancer (CLB) - Legacy
- Basic Layer 4 and Layer 7 load balancing
- Fixed hostname
- EC2-Classic network support
- Not recommended for new applications

When to use each type:
- ALB: Modern web applications, microservices, container-based applications
- NLB: TCP/UDP applications, extreme performance requirements, static IP needs
- CLB: Only for existing applications in EC2-Classic network

Common Use Cases:
- High Availability: Distribute traffic across multiple AZs
- Auto Scaling: Dynamically adjust capacity based on demand
- SSL Termination: Offload SSL/TLS decryption
- Blue-Green Deployments: Zero-downtime deployments
- A/B Testing: Test new application versions
- Security: Single point for security policies and SSL certificates
