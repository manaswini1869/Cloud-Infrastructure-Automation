# Cloud-Infrastructure-Automation

# Project 1

This Terraform configuration sets up a basic AWS infrastructure consisting of a custom VPC with public subnet, internet gateway, route table, security group, network interface, Elastic IP, and an Ubuntu web server instance running Apache.  

**Configuration Details**  
- **VPC**: Creates a custom VPC (prod_vpc) with a CIDR block of 10.0.0.0/16.  
- **Internet Gateway**: Attaches an internet gateway (prod_gw) to the VPC for internet access.  
- **Route Table**: Creates a custom route table (prod_rt) and associates it with the internet gateway to enable internet traffic.  
- **Subnet**: Creates a public subnet (prod_subnet) with a CIDR block of 10.0.1.0/24 and associates it with the custom route table.  
- **Security Group**: Creates a security group (allow_web) allowing inbound traffic on ports 22 (SSH), 80 (HTTP), and 443 (HTTPS), and all outbound traffic.  
- **Network Interface**: Creates a network interface (prod_server_nic) with a private IP address in the subnet and attaches it to the security group.  
- **Elastic IP**: Assigns an Elastic IP (one) to the network interface for static public IP addressing.  
- **Ubuntu Web Server Instance**: Launches an Ubuntu server instance (web_server_instance) in the public subnet, configures Apache, and serves a default webpage.  

# Project 2

s3bucketsimple  
- This CloudFormation template creates an Amazon S3 bucket with specified configurations.  

ec2withsitev2  
- This CloudFormation template provisions an EC2 instance with Apache installed.  

# Project 3 

This Terraform configuration automates the setup of an AWS Lambda function that tags newly launched EC2 instances with the owner's username.    

**Configuration Details**  

**Provider Information**  
Specifies the required provider (AWS) and its version.  

**Configuration**  
Configures the AWS provider with the specified region and path to shared credentials file.  

**Lambda Information**  
- Defines an IAM role (lambda_iam) for the Lambda function with a policy allowing Lambda service to assume the role.  
- Creates an IAM policy (lambda_ec2_policy) for the Lambda function to execute EC2 actions and write logs to CloudWatch Logs.  
- Attaches the IAM policy to the IAM role.  
- Archives the Lambda function code.  
- Creates the Lambda function (lambda_ec2_tags_function) with specified configuration such as runtime, handler, and dependencies on IAM role and  policy attachment. 

**CloudTrail Logs and EventBridge Detection**  
- Defines a CloudWatch Events rule to capture EC2 RunInstances events.  
- Sets up a CloudWatch Events target to trigger the Lambda function when specified events occur.  

**Lambda Function Code**  
- The Lambda function code (main.py) retrieves the username and instance ID from the CloudWatch Event and creates a tag for the instance with the owner's username.  