# Automating Infrastructure and Software Configuration with Terraform, Ansible, Jenkins, and Docker

This project aims to automate the provisioning and configuration of infrastructure and software for setting up a remote desktop environment using Terraform, Ansible, Jenkins, and Docker.



## **The process involves the following Key Steps:**

1. **Provision Jenkins Server**: Create the necessary infrastructure on Google Cloud Platform (GCP) using Terraform. This includes a Virtual Private Cloud (VPC), a Service Account, and a Virtual Machine (VM) instance configured as a Jenkins server.

2. **Provision Ubuntu Desktop Server**: Use another Terraform script to provision a VM instance running Ubuntu 20.04. This VM will connect to the previously created VPC and serve as a remote desktop environment.

3. **Configure Ubuntu Desktop Server**: Use an Ansible playbook to install necessary software on the Ubuntu Desktop server, including Python and Chrome Remote Desktop, and set up the desktop environment.

4. **Execute Configuration via Jenkins**: Configure the Jenkins server to run jobs using Docker agent nodes. These jobs will execute the Terraform scripts and the Ansible playbook to provision and configure the Ubuntu Desktop server.

5. **Access Remote Desktop**: Access the desktop environment on the Ubuntu Desktop VM instance remotely using Chrome Remote Desktop.

## Prerequisites

1. Base VM with “Git”, “Terraform”, “And Docker” Installed in it & “Service-account” with appropriate permission to create 
   Infrastructure.
2. Docker Hub Account.


## Workflow for “Base-VM”:

### Step 1: Create a VM instance with Ubuntu OS.

### Step 2: Connect to VM-instance SSH – Terminal and run the following commands.

```
    gcloud auth application-default login  
``` 
#### OR

```
    gcloud auth print-access-token

    export TOKEN="PASTE THE ABOVE GENERATED TOKEN HERE"
```
### Step 3: Install Git, Terraform, Docker.

```
    # Update packages
      sudo apt update

    # Git installation
      sudo apt install git -y

    # Terraform installation

     wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
     echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
     sudo apt update && sudo apt install terraform

    #Docker Installation

    sudo apt install docker.io -y
    sudo systemctl daemon-reload
    sudo systemctl restart docker

```
### Step 4: Clone Repo to local as “root user”: 
```
    • sudo su
    • git clone https://github.com/bpurnachander/get-ubuntudesktop-iac.git
```

### Step 5:Building image and pushing to Docker Hub.
```
      cd get-ubuntudesktop-iac

    # Build and push image to Docker Hub

      docker login

    # Provide Docker Hub credentials(username & password)

```
![alt text](image.png)
```
docker build -t username/repo_name .
docker push username/repo_name
```
![alt text](image-1.png)
![alt text](image-2.png)

### Step 6: Creating Infrastructure using terraform.
```
    cd /root/get-ubuntudesktop-iac/terraform
    terraform init
    terraform plan
    terraform apply --auto-approve
```
> [!IMPORTANT] 
> Make sure to change necessary sections like **Project-ID**, **Backup-bucket-name** & **Source Path** in the **main.tf** file 
  with your details.

![alt text](image-3.png)

### Step 7: Connect to jenkins VM-instance SSH – Terminal & get Jenkins UI Password.
```
cat /var/lib/jenkins/secrets/initialAdminPassword
```
![alt text](image-4.png)

### Step 8: Connecting to “Jenkins-UI”.

>        Browse “Jenkins-server-Public-IP:8080” and paste above “password” here.
![alt text](image-5.png)
![alt text](image-6.png)
![alt text](image-7.png)

>**Add new “Jenkins credentials”.**
![alt text](image-8.png)
![alt text](image-9.png)
![alt text](image-10.png)

### Step 9: Installing necessary plugins: 
            - Docker
            - Pipeline Stage View
```
        Dashboard--> Manage Jenkins--> Plugins --> Available plugins --> "search for plugins & Install"
```
![alt text](image-11.png)

### Step 10: Adding global credentials for:
            - Docker Hub.
            - Jenkins agent.
            - Service-account JSON key.
> Adding Docker Hub credentials.
```
Manage Jenkins -> credentials -> global -> add credentials -> kind (username &
password) -> username & password (docker-hub username & password) -> Id(docker-hub) 
-> save
```
![Docker Hub credentials](image-12.png)

>Adding Jenkins-agent credentials.
```
Manage Jenkins --> credentials -> global -> add credentials -> kind (username &
password) -> username (jenkins) -> password (password) -> Id (jenkins-user)-> save
```
![Jenkins-agent](image-13.png)

>Adding Service-account json key credentials
```
Manage Jenkins --> credentials -> global -> add credentials -> kind (Secret file) 
-> File(Choose file)--> ID(svc-json)-> save
```
![svc](image-14.png)

### Step 11: Create new Pipeline job
```
Dashboard--> + New Item--> Enter an item name(desktop)--> Pipeline--> OK

NOTE: Kindly add your pipeline name as per the path of terraform code . 

source = "/var/lib/jenkins/workspace/Youre-pipeline-Name/terraform-folder-Namae/modules/desktop-server"
```
>E.g:
![alt text](image-15.png)
![alt text](image-16.png)

### Step 12: Integrating Git for source code.
```
Pipeline-->Definition(Pipeline script from SCM)--> SCM(Git)--> Repositories
--> Repository URL(https://github.com/bpurnachander/get-ubuntudesktop-iac.git)
--> Branches to build--> Branch Specifier(*/main)-->Script Path(Jenkins)--> Save
```
![alt text](image-17.png)
![alt text](image-18.png)

### Step 13: Adding parameters
```
This Project is Parameterized
--> Add Parameter
--> Choice Parameter--> Name(tfm_action)--> Choices(apply, destroy, ansible)
```
![alt text](image-19.png)
```
--> Add Parameter
--> Choice Parameter--> Name(ansible_action)--> Choices(---, apply, destroy)
```
![alt text](image-20.png)
```
--> Add Parameter
--> Choice Parameter--> Name(target_hosts)--> Choices(---, desktop, apache2)
```
![alt text](image-21.png)

### Step 14: Configuring Docker as Jenkins-agent.
```
Dashboard--> Manage Jenkins--> Clouds--> New cloud--> Cloud name(docker)--> Type
--> Docker(select it)-->Create
```
![alt text](image-22.png)
```
	--> Docker Cloud details--> Docker Host URI--> tcp://Public-IP:4243--> Test Connection
	    Output will be like(Version = 24.0.5, API Version = 1.43)
	-->Enabled(click it)
```
![alt text](image-23.png)
```
    --> Docker Agent templates--> Add Docker Template--> Labels-->docker--> Enabled
    --> Name--> docker-agent--> Docker Image--> GIVE YOUR IMAGE
```
![alt text](image-24.png)
```
	--> Registry Authentication(select Docker Hub credentials ID)
	--> Remote File System Root--> /var/lib/jenkins
```
![alt text](image-25.png)
```
	--> Usage--> Only build jobs with label expressions matching this node
	--> Connect method--> Connect with SSH--> SSH key--> use configured SSH credentials
```
![alt text](image-26.png)
```
	--> SSH Credentials--> SSH Credentials(select jenkins-agent credentials ID)
	-->Host Key Verification Strategy-->Non verifying strategy-->save.
```
![alt text](image-27.png)

### Step 15: Build your pipeline with appropriate choices.
![alt text](image-28.png)
![alt text](image-29.png)


## If you found this repo useful, give it a STAR 🌠
