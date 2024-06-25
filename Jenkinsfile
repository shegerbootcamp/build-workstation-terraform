pipeline {
    agent {
        dockerfile true
    }

    parameters {
        string(name: 'name', defaultValue: '', description: 'The name variable for Terraform')
        string(name: 'awsCredentialsId', defaultValue: '', description: 'AWS credentials ID')
        //booleanParam(name: 'destroy', defaultValue: false, description: 'Check this to run destroy')
        string(name: 'bucketname', defaultValue: 'ssh-aws-parameter-store', description: 'S3 bucket name for Terraform backend')
        choice (name: 'ACTION',
				choices: [ 'plan', 'apply', 'destroy'],
				description: 'Run terraform plan / apply / destroy')
    }

    stages {
        stage('Download terraform.tfvars') {
            steps {
                downloadTerraformTFVars()
            }
        }

        stage('Initialize') {
            steps {
                initializeTerraform()
            }
        }

        stage('Plan') {
            when { anyOf
					{
						environment name: 'ACTION', value: 'plan';
						environment name: 'ACTION', value: 'apply'
					}
				}
            steps {
                planTerraform()
            }
        }

        stage('Apply') {
            when { anyOf
					{
						environment name: 'ACTION', value: 'apply'
					}
				}
            steps {
                applyTerraform()
            }
        }

        stage('Destroy') {
            when { anyOf
					{
						environment name: 'ACTION', value: 'destroy'
					}
				}
            steps {
                destroyTerraform()
            }
        }
    }
}

def downloadTerraformTFVars() {
    script {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: params.awsCredentialsId]]) {
            sh 'aws s3 cp s3://tfvars2024/terraform.tfvars .'
        }
        stash includes: 'terraform.tfvars', name: 'tfvars'
    }
}

def initializeTerraform() {
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

def planTerraform() {
    script {
            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: params.awsCredentialsId]]) {
                sh "terraform plan -var-file=terraform.tfvars -var='name=${params.name}'"
        }
    }
}

def applyTerraform() {
    script {
            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: params.awsCredentialsId]]) {
                sh "terraform apply -var-file=terraform.tfvars -var='name=${params.name}' -auto-approve"
        }
    }
}

def destroyTerraform() {
    script {

            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: params.awsCredentialsId]]) {
                sh "terraform init -reconfigure -backend-config=bucket=${params.bucketname}"
                sh "terraform workspace select ${params.name}"
                sh "terraform destroy -var-file=terraform.tfvars -var='name=${params.name}' -auto-approve"
                
            }
        }
    }
