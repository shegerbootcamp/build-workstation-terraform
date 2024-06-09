pipeline {
    agent any

    parameters {
        string(name: 'name', defaultValue: '', description: 'The name variable for Terraform')
        string(name: 'awsCredentialsId', defaultValue: '', description: 'AWS credentials ID')
    }

    stages {
        stage('Download terraform.tfvars') {
            steps {
                script {
                    // Download terraform.tfvars from S3 bucket
                    sh 'aws s3 cp s3://tfvars2024/terraform.tfvars .'
                }
            }
        }

        stage('Initialize') {
            steps {
                script {
                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Plan') {
            steps {
                script {
                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: params.awsCredentialsId]]) {
                            sh "terraform plan -var-file=terraform.tfvars -var='name=${params.name}'"
                        }
                    }
                }
            }
        }

        stage('Apply') {
            steps {
                script {
                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        input message: "Are you sure you want to apply changes?", ok: "Yes"
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: params.awsCredentialsId]]) {
                            sh "terraform apply -var-file=terraform.tfvars -var='name=${params.name}'"
                        }
                    }
                }
            }
        }

        stage('Destroy') {
            steps {
                script {
                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        input message: "Are you sure you want to destroy resources?", ok: "Yes"
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: params.awsCredentialsId]]) {
                            sh "terraform destroy -var-file=terraform.tfvars -var='name=${params.name}'"
                        }
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
