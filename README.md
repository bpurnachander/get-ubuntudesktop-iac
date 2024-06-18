# Automating Infrastructure and Software Configuration with Terraform, Ansible, Jenkins, and Docker

This project aims to automate the provisioning and configuration of infrastructure and software for setting up a remote desktop environment using Terraform, Ansible, Jenkins, and Docker.

## <span style="color: red;">The process involves the following Key Steps:</span>

1. **Provision Jenkins Server**: Create the necessary infrastructure on Google Cloud Platform (GCP) using Terraform. This includes a Virtual Private Cloud (VPC), a Service Account, and a Virtual Machine (VM) instance configured as a Jenkins server.

2. **Provision Ubuntu Desktop Server**: Use another Terraform script to provision a VM instance running Ubuntu 20.04. This VM will connect to the previously created VPC and serve as a remote desktop environment.

3. **Configure Ubuntu Desktop Server**: Use an Ansible playbook to install necessary software on the Ubuntu Desktop server, including Python and Chrome Remote Desktop, and set up the desktop environment.

4. **Execute Configuration via Jenkins**: Configure the Jenkins server to run jobs using Docker agent nodes. These jobs will execute the Terraform scripts and the Ansible playbook to provision and configure the Ubuntu Desktop server.

5. **Access Remote Desktop**: Access the desktop environment on the Ubuntu Desktop VM instance remotely using Chrome Remote Desktop.

For detailed scripts and configuration files, refer to the GitHub repository: [get-ubuntudesktop-iac](https://github.com/bpurnachander/get-ubuntudesktop-iac).

## Prerequisites

1. Default GCP VM with Firewall-http-server
2. Git (version 2.25.1)
3. Terraform (v1.8.5)
4. Storage Bucket
5. Docker Hub Account
6. Docker Installation
7. Service Account IAM permissions for the base VM:
   - Compute Admin
   - Compute Instance Admin v1
   - Compute Network Admin
   - Service Account User

## Base VM Setup

### Step 1: Create a Base VM Instance with Ubuntu OS

### Step 2: Install Terraform and Docker

1. SSH into the VM instance.
2. Run the following commands to install Terraform and Docker:

    ```bash
    sudo apt-get update

    # Terraform Installation
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install terraform

    # Docker Installation
    sudo apt install docker.io -y
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    ```

3. Clone the GitHub repository:

    ```bash
    git clone https://github.com/bpurnachander/get-ubuntudesktop-iac
    ```

### Step 3: Configure Terraform

1. Authenticate with GCP:

    ```bash
    gcloud auth application-default login
    # OR
    gcloud auth print-access-token
    export TOKEN="PASTE THE ABOVE GENERATED TOKEN HERE"
    ```

2. Navigate to the Terraform directory and run the Terraform commands:

    ```bash
    cd /get-ubuntudesktop-iac/terraform-jenkins/
    terraform init
    terraform validate
    terraform plan
    terraform apply --auto-approve
    ```

### Build and Push Docker Image

1. Build and push the Docker image to Docker Hub:

    ```bash
    docker login
    # Enter Docker Hub username and password
    docker build -t $image_name:tag .
    docker images 
    docker tag $image_name:tag $username/repo_name
    docker push $username/repo_name
    ```

## Jenkins Configuration

### Login to Jenkins Server

1. Install required plugins:
   - Docker
   - Pipeline Stage View

### Add Global Credentials

1. Docker Hub credentials:

    ```bash
    Manage Jenkins -> credentials -> global -> add credentials -> kind (username & password) -> username & password (Docker Hub username & password) -> Id (docker-hub) -> save
    ```

2. User created by Docker image:

    ```bash
    Manage Jenkins -> credentials -> global -> add credentials -> kind (username & password) -> username (jenkins) -> password (password) -> Id (jenkins-user) -> save
    ```

3. Service account credentials:

    ```bash
    Manage Jenkins -> credentials -> global -> add credentials -> kind (secret file) -> File -> Id () -> save
    ```

### Docker Agent Configuration

1. Configure Docker agent as a slave node:

    ```bash
    Manage Jenkins -> Cloud -> New cloud (give name) -> Select (docker) Create
    ```

2. Fill in Docker cloud details:

    ```bash
    Docker host URL = tcp:$JENKINS_SERVER_EXTERNAL_IP:4243
    ```

3. Fill in Docker agent templates:

    ```bash
    Labels (docker) -> select (Enabled)
    Name (docker-agent)
    Docker Image (give your DOCKER_HUB REPO PATH)
    Select (Registry Authentication) -> Credentials (select DOCKER-HUB credential ID)
    Remote File System Root (/var/lib/jenkins)
    Usage (only build jobs label expression matching this node)
    Connect method (Use Configured SSH credentials)
    SSH credentials (Select Jenkins-user Credential ID)
    Host Key Verification Strategy (Non-Verifying verification strategy) -> save
    ```

### Configure Jenkins Pipeline

1. Parameterize the job:

    ```bash
    This project is parameterized (select) -> (select) choice Parameters
    Name = action
    Choices: apply
             destroy
    ```

2. Define the pipeline script from SCM:

    ```bash
    Repository URL: https://github.com/bpurnachander/get-ubuntudesktop-iac.git
    Branch Specifier: */main
    Script Path: Jenkinsfile -> save -> Build the Job
    ```

## Chrome Remote Desktop Setup

1. Access [Chrome Remote Desktop](https://remotedesktop.google.com/access/).
2. Follow the instructions to set up remote access.
3. Paste the Debian Linux link into the Desktop-Server SSH Terminal.
4. Set up the hostname and PIN.
5. Access your remote desktop from the Chrome Remote Desktop site.

## Troubleshooting

### Common Errors

1. **Connection refused**:
   - Cause: Openssh-client not working properly.
   - Remedy: Wait for a few seconds after VM is created.

2. **Permission denied**:
   - Cause: User has no permission to use private key.
   - Remedy: Check the user type and change permissions of the private key.

3. **Host key verification failed**:
   - Cause: Unable to verify Host key.
   - Remedy:

    ```bash
    echo 'host_key_checking = False' | sudo tee -a /etc/ansible/ansible.cfg
    ```

4. **Error: Jenkins doesn’t have label ‘docker-agent’**:
   - Remedy: Check Slave User credentials.

### Terraform Errors

1. **Error 409: Resource Already Exists**:
2. **Error 400: Syntax Error**:
   - Remedy: Check the syntax in Terraform script.

3. **Error 404: API error**:
   - Remedy: Enable API for the resources to be created.

4. **Error: State lock**:
   - Remedy: Remove the lock file manually or terminate the running Terraform processes.

    ```bash
    cd /Path/to/terraform/
    rm .terraform.tfstate.lock.info
    ps aux | grep terraform
    kill -9 <PID>
    # For eg: kill -9 1425
    terraform apply
    ```

For more detailed information and troubleshooting, refer to the project repository: [get-ubuntudesktop-iac](https://github.com/bpurnachander/get-ubuntudesktop-iac).
