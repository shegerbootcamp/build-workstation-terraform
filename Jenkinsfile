pipeline {
    agent any
    
    environment {
        SSH_USERNAME = ''
    }
    
    parameters {
        string(name: 'SSH_USERNAME', defaultValue: '', description: 'SSH username for Terraform deployment')
    }
    
    stages {
        stage('Initialize') {
            steps {
                sh 'make init SSH_USERNAME=${SSH_USERNAME}'
            }
        }
        
        stage('Plan') {
            steps {
                sh 'make plan SSH_USERNAME=${SSH_USERNAME}'
            }
        }
        
        stage('Apply') {
            steps {
                sh 'make apply SSH_USERNAME=${SSH_USERNAME}'
            }
        }
        
        stage('Destroy') {
            steps {
                sh 'make destroy SSH_USERNAME=${SSH_USERNAME}'
            }
        }
    }
}
