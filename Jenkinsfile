pipeline {
    agent {
        dockerfile true
    }

    parameters {
        string(name: 'name', defaultValue: '', description: 'The name variable for Terraform')
        string(name: 'awsCredentialsId', defaultValue: '', description: 'AWS credentials ID')
        booleanParam(name: 'destroy', defaultValue: false, description: 'Check this to run destroy')
        string(name: 'bucketname', defaultValue: '', description: 'S3 bucket name for Terraform backend')
    }

    stages {
        stage('Download terraform.tfvars') {
            steps {
                script {
                    // Download terraform.tfvars from S3 bucket
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: params.awsCredentialsId]]) {
                        sh 'aws s3 cp s3://tfvars2024/terraform.tfvars .'
                    }
                    stash includes: 'terraform.tfvars', name: 'tfvars'
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
                    unstash 'tfvars'
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: params.awsCredentialsId]]) {
                        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                            sh 'terraform init'
                        }
                        sh "terraform workspace new ${params.name} || terraform workspace select ${params.name}"
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
                    unstash 'tfvars'
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
                    unstash 'tfvars'
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
                        unstash 'tfvars'
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: params.awsCredentialsId]]) {
                            sh "terraform init -reconfigure -backend-config=bucket=${params.bucketname}"
                            sh "terraform workspace select ${params.name}"
                            def destroyOutput = sh(script: "terraform destroy -auto-approve -var-file=terraform.tfvars -var='name=${params.name}'", returnStdout: true).trim()
                            echo destroyOutput
                            if (destroyOutput.contains("No changes. Infrastructure is up-to-date.") || destroyOutput.contains("Destroy complete! Resources: 0 destroyed.")) {
                                error("No resources to destroy")
                            }
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
