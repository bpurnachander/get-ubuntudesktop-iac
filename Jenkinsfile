pipeline {
    agent {
        label 'docker'
    }
    environment {
        // Add your json file credentials-ID here
        GCP_CREDENTIALS = credentials('svc-json')
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/bpurnachander/get-ubuntudesktop-iac.git'
            }
        }
        stage('tfm-init') {
            when {
                expression {
                    return tfm_action == 'apply' || tfm_action == 'destroy'
                }
            }
            steps {
                sh '''
                cd /var/lib/jenkins/workspace/desktop/terraform-desktop
                terraform init
                '''
            }
        }
        stage('tfm-plan') {
            when {
                expression {
                    return tfm_action == 'apply'
                }
            }
            steps {
                sh '''
                cd /var/lib/jenkins/workspace/desktop/terraform-desktop
                terraform plan
                '''
            }
        }
        stage('tfm-apply') {
            when {
                expression {
                    return tfm_action == 'apply'
                }
            }
            steps {
                sh '''
                cd /var/lib/jenkins/workspace/desktop/terraform-desktop
                terraform $tfm_action --auto-approve
                '''
            }
        }
        stage('tfm-destroy') {
            when {
                expression {
                    return tfm_action == 'destroy'
                }
            }
            steps {
                sh '''
                cd /var/lib/jenkins/workspace/desktop/terraform-desktop
                terraform $tfm_action --auto-approve
                '''
            }
        }
        stage('ansible.cfg') {
            when {
                expression {
                    return tfm_action == 'ansible'
                }
            }
            steps {
                sh 'cat ./ansible/ansible.cfg | sudo tee /etc/ansible/ansible.cfg'
            }
        }
        stage('Copy svc_credentials') {
            when {
                expression {
                    return tfm_action == 'ansible'
                }
            }
            steps {
                script {
                    // Define the path where the GCP credentials will be copied on the slave agent
                    def destPath = '/var/lib/jenkins/workspace/desktop/ansible/service-account.json'

                    // Write the secret file to the destination path on the slave agent
                    writeFile file: destPath, text: new String(readFile(env.GCP_CREDENTIALS).bytes)
                }
            }
        }
        stage('Playbook-apply'){
             when {
                expression {
                    return tfm_action == 'ansible' && ansible_action == 'apply'
                }
            }
            steps {
                sh 'ansible-playbook -e "target_hosts=$target_hosts" -e "operation=$ansible_action" ansible/master.yaml'
            }
        }
        stage('Playbook-destroy'){
             when {
                expression {
                    return tfm_action == 'ansible' && ansible_action == 'destroy'
                }
            }
            steps {
                sh 'ansible-playbook -e "target_hosts=$target_hosts" -e "operation=$ansible_action" ansible/master.yaml'
            }
        }
        stage('Upgrade tomcat Version') {
             when {
                expression {
                    return upgrade_software == 'tomcat'
                }
            }
            steps {
                script {
                    def oldVersions = sh(script: "ansible $ansible_hosts -a 'grep apache-tomcat'", returnStdout: true).trim()
                    
                    if (oldVersions) {
                        echo "Found the following Tomcat versions:"
                        echo oldVersions
                        
                        def userInput = input message: 'Do you want to upgrade your tomcat version?', ok: 'Yes'
                        
                        
                        echo "You chose to upgrade to Tomcat version: $tomcat_version"
                    } else {
                        sleep(time: 15, unit: 'SECONDS')
                
                        sh '''
                        ansible-playbook -e "ansible_hosts=$ansible_hosts software=$software python_version=$python_version java_version=$java_version tomcat_base_version=$tomcat_base_version tomcat_version=$tomcat_version operation=apply" adq-ubuntu-desktop/ansible/master.yaml
                        '''
                    }
                }
            }
        }
    }
}
