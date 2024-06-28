
---

# Jenkins Pipeline for Workstation Creation and Termination

This Jenkins pipeline automates the process of creating and terminating a development workstation on AWS EC2. It assumes you have an AWS account and appropriate IAM roles set up for Jenkins to interact with AWS services.

## Pipeline Overview

### Stage 1: Create Workstation

1. **Input Parameters:**
   - `user_name`: The username for the developer workstation.

2. **Execution:**
   - Uses AWS CLI (`aws ec2 run-instances`) to launch a new EC2 instance (workstation) based on provided parameters.
   - Tags the instance appropriately for identification and tracking.

3. **Verification:**
   - Monitors the AWS console or uses AWS CLI (`aws ec2 describe-instances`) to verify that the EC2 instance has been successfully created.
   - Waits for Watchmaker (or other configuration management tool) to complete its setup on the instance.

### Stage 2: Verify EC2 Instance and Watchmaker Completion

1. **Execution:**
   - Continuously checks the AWS EC2 instance state and Watchmaker completion status.
   - Proceeds to the next stage once the EC2 instance is running and Watchmaker has completed its configuration.

### Stage 3: Post-Build Actions

1. **Execution:**
   - Upon a successful build (green build), SSH into the DevOps workstation.
   - Run a script (`ssh-key-retrieve.sh`) to download the user's SSH public and private keys.
   - Ensure AWS CLI is properly configured on the DevOps workstation for this step.

2. **Key Conversion (if necessary):**
   - Convert the downloaded SSH private key from PEM to PPK format if using Putty for SSH access.

### Stage 4: Notification to Developer

1. **Outcome:**
   - After successful completion, notify the developer with the following information:
     - Workstation IP address.
     - Public and private SSH keys for accessing the workstation.

