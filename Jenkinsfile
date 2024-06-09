pipeline {
    agent any

    environment {
        SSH_USERNAME = '' // Set the SSH_USERNAME here or pass it as a parameter
    }

    parameters {
        string(name: 'SSH_USERNAME', defaultValue: '', description: 'The SSH username to use for Terraform workspace')
        string(name: 'AWS_CREDENTIALS_ID', defaultValue: '', description: 'The AWS credentials ID to use')
        booleanParam(name: 'DESTROY', defaultValue: false, description: 'Check this to run destroy after apply')
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("my-terraform-image", ".")
                }
            }
        }

        stage('Init') {
            agent {
                docker {
                    image 'my-terraform-image'
                }
            }
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: params.AWS_CREDENTIALS_ID]]) {
                        if (!params.SSH_USERNAME) {
                            error "SSH_USERNAME is not set. Please provide SSH_USERNAME."
                        }
                        sh "make init SSH_USERNAME=${params.SSH_USERNAME}"
                    }
                }
            }
        }

        stage('Plan') {
            agent {
                docker {
                    image 'my-terraform-image'
                }
            }
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: params.AWS_CREDENTIALS_ID]]) {
                        if (!params.SSH_USERNAME) {
                            error "SSH_USERNAME is not set. Please provide SSH_USERNAME."
                        }
                        sh "make plan SSH_USERNAME=${params.SSH_USERNAME}"
                    }
                }
            }
        }

        stage('Apply') {
            agent {
                docker {
                    image 'my-terraform-image'
                }
            }
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: params.AWS_CREDENTIALS_ID]]) {
                        if (!params.SSH_USERNAME) {
                            error "SSH_USERNAME is not set. Please provide SSH_USERNAME."
                        }
                        input message: "Are you sure you want to apply changes?", ok: "Yes"
                        sh "make apply SSH_USERNAME=${params.SSH_USERNAME}"
                    }
                }
            }
        }

        stage('Destroy') {
            when {
                expression { return params.DESTROY }
            }
            agent {
                docker {
                    image 'my-terraform-image'
                }
            }
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: params.AWS_CREDENTIALS_ID]]) {
                        if (!params.SSH_USERNAME) {
                            error "SSH_USERNAME is not set. Please provide SSH_USERNAME."
                        }
                        sh "make destroy SSH_USERNAME=${params.SSH_USERNAME}"
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
