# Lambda
AWS Lambda is a serverless computing service provided by AWS that automatically runs code in response to events, scales dynamically, and charges only for the compute time used. It supports multiple programming languages, integrates with many AWS services, and is commonly used for tasks like data processing, running APIs, and automation workflows, all without managing infrastructure

# How Lambda Functions Fit into the Serverless World
At the heart of AWS Lambda are "Lambda functions." These are individual units of code that perform specific tasks. Think of them as small, single-purpose applications that run independently.

# Here's how Lambda functions fit into the serverless world:
    - Event-Driven Execution: Lambda functions are triggered by events. An event could be anything, like a new file being uploaded to Amazon S3, a request hitting an API, or a specific time on the clock. When an event occurs, Lambda executes the corresponding function.

    - No Server Management: As a developer, you don't need to worry about managing servers. AWS handles everything behind the scenes. You just upload your code, configure the trigger, and Lambda takes care of the rest.

    - Automatic Scaling: Whether you have one user or one million users, Lambda scales automatically. Each function instance runs independently, ensuring that your application can handle any level of incoming traffic without manual intervention.

    - Pay-per-Use: One of the most attractive features of serverless computing is cost efficiency. With Lambda, you pay only for the compute time your code consumes. When your code isn't running, you're not charged.

    - Supported Languages: Lambda supports multiple programming languages like Node.js, Python, Java, Go, and more. You can choose the language you are comfortable with or that best fits your application's needs.


# Features of AWS Lambda
Serverless Architecture: No need to manage infrastructure. AWS handles provisioning, scaling, and maintenance.
Auto-scaling: Automatically scales up or down based on the workload.
Cost-effective: You only pay for the execution time (in milliseconds) and the resources used.
Supports multiple triggers:
AWS S3 (file uploads)
DynamoDB (data changes)
CloudWatch (scheduled events)
API Gateway (HTTP requests)
EventBridge, SNS, Kinesis, etc.
Stateless: Each invocation of a Lambda function is independent. Persistent data must be stored externally (e.g., in DynamoDB or S3).

# Use Cases of AWS Lambda
Data processing: Real-time file processing when files are uploaded to S3.
Serverless APIs: Using API Gateway to trigger Lambda for backend logic.
Automated workflows: Triggering code based on changes in a DynamoDB table or scheduled CloudWatch events.
IoT backend: Processing data from IoT devices.
ML inference: Running lightweight machine learning models in response to events.

# Lifecycle of AWS Lambda
Event source triggers the Lambda function.
The Lambda service fetches the code and starts a container.
Lambda executes the handler function in response to the event.
Logs and metrics are automatically pushed to Amazon CloudWatch.

# Pricing Model
AWS Lambda is charged based on:

Number of requests: Free tier includes 1 million requests per month.
Compute time: Based on the memory size allocated and execution time (measured in milliseconds).

# Account-wide Limits for AWS Lambda
Number of Lambda Functions:
By default, an AWS account can have 1,000 Lambda functions per region.
You can request an increase if needed by contacting AWS Support.

# Concurrent Executions:
The default concurrent execution limit per AWS account is 1,000 across all functions in a region.
You can increase this limit by making a request to AWS Support.
For specific reserved concurrency, you can allocate limits to individual functions to ensure availability.

# Using AWS Management Console
Log in to AWS Console.
Navigate to Service Quotas:
Go to the Service Quotas page (search for it in the search bar).
Select AWS Lambda from the services list.
Check for:
Concurrent Executions: Default limit is 1,000 per region.
Function and Layer Count: Displays the number of functions allowed per region.

# Activities
1. Automate EC2 Instance Management
    - Start or stop EC2 instances based on schedules (e.g., turn off instances at night to save costs).
    - Resize underutilized instances to optimize resource usage.
    - Automatically Delete Unused EBS Volumes and Snapshots
    - Monitor EC2 instance health and take necessary actions.
2. Monitor and Enforce Security Best Practices
    - Disable old IAM user access keys that exceed a defined age.
    - Enforce password policies and notify administrators of policy violations.
    - Monitor and restrict security group changes to prevent misconfigurations.
    - Identify and remediate publicly accessible S3 buckets.
3. Cleanup Unused Resources
    - Delete unused (available) EBS volumes to reduce storage costs.
    - Remove orphaned snapshots (snapshots not associated with active EBS volumes).
    - Clean up old CloudWatch log groups that exceed a retention threshold.
    - Automatically delete expired S3 objects or unused data to save on storage costs.
4. Automate Backups and Recovery
    - Trigger on-demand backups for DynamoDB tables or RDS instances.
    - Automatically create AMIs (Amazon Machine Images) for EC2 instances for disaster recovery.
    - Rotate and clean up old backups to adhere to retention policies
5. Scaling and Resource Optimization
    - Scale RDS instances up or down based on CPU or memory utilization metrics.
    - Resize Lambda function memory and execution time limits to optimize cost and performance.
    - Scale ECS (Elastic Container Service) tasks or Fargate services based on demand.