pipeline {
    agent {
        dockerfile true
    }

    parameters {
        string(name: 'name', defaultValue: '', description: 'The name variable for Terraform')
        string(name: 'awsCredentialsId', defaultValue: '', description: 'AWS credentials ID')
        booleanParam(name: 'destroy', defaultValue: false, description: 'Check this to run destroy')
    }

    stages {
        stage('Download terraform.tfvars') {
            when {
                not {
                    expression { return params.destroy }
                }
            }
            steps {
                script {
                    // Download terraform.tfvars from S3 bucket
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: params.awsCredentialsId]]) {
                        sh 'aws s3 cp s3://tfvars2024/terraform.tfvars .'
                    }
                }
            }
        }

        stage('Initialize') {
            when {
                not {
                    expression { return params.destroy }
                }
            }
            steps {
                script {
                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Plan') {
            when {
                not {
                    expression { return params.destroy }
                }
            }
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
            when {
                not {
                    expression { return params.destroy }
                }
            }
            steps {
                script {
                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: params.awsCredentialsId]]) {
                            sh "terraform apply -var-file=terraform.tfvars -var='name=${params.name}' -auto-approve"
                        }
                    }
                }
            }
        }

        stage('Destroy') {
            when {
                expression { return params.destroy }
            }
            steps {
                script {
                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        input message: "Are you sure you want to destroy resources?", ok: "Yes"
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: params.awsCredentialsId]]) {
                            sh "terraform destroy -var-file=terraform.tfvars -var='name=${params.name}' -auto-approve"
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
