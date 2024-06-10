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
                    stash includes: 'terraform.tfstate, terraform.tfstate.*', name: 'tfstate'
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
                    unstash 'tfstate'
                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: params.awsCredentialsId]]) {
                            sh "terraform apply -var-file=terraform.tfvars -var='name=${params.name}' -auto-approve"
                        }
                    }
                    stash includes: 'terraform.tfstate, terraform.tfstate.*', name: 'tfstate'
                }
            }
        }

        stage('Destroy') {
            when {
                expression { return params.destroy }
            }
            steps {
                script {
                    unstash 'tfvars'
                    unstash 'tfstate'
                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        input message: "Are you sure you want to destroy resources?", ok: "Yes"
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: params.awsCredentialsId]]) {
                            def destroyOutput = sh(script: "terraform destroy -var-file=terraform.tfvars -var='name=${params.name}' -auto-approve", returnStdout: true).trim()
                            echo destroyOutput

                            if (destroyOutput.contains("No changes. Infrastructure is up-to-date.")) {
                                error("No resources to destroy")
                            } else if (destroyOutput.contains("Destroy complete! Resources: 0 destroyed.")) {
                                error("No resources were destroyed")
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
