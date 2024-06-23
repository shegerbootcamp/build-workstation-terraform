// vars/terraformUtils.groovy

def downloadTerraformTFVars(awsCredentialsId) {
    script {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: awsCredentialsId]]) {
            sh 'aws s3 cp s3://tfvars2024/terraform.tfvars .'
        }
        stash includes: 'terraform.tfvars', name: 'tfvars'
    }
}

def initializeTerraform(awsCredentialsId, name) {
    script {
        unstash 'tfvars'
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: awsCredentialsId]]) {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                sh 'terraform init'
            }
            sh "terraform workspace new ${name} || terraform workspace select ${name}"
        }
    }
}

def planTerraform(awsCredentialsId, name) {
    script {
        unstash 'tfvars'
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: awsCredentialsId]]) {
                sh "terraform plan -var-file=terraform.tfvars -var='name=${name}'"
            }
        }
    }
}

def applyTerraform(awsCredentialsId, name) {
    script {
        unstash 'tfvars'
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: awsCredentialsId]]) {
                sh "terraform apply -var-file=terraform.tfvars -var='name=${name}' -auto-approve"
            }
        }
    }
}

def destroyTerraform(awsCredentialsId, name, bucketname) {
    script {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
            input message: "Are you sure you want to destroy resources?", ok: "Yes"
            unstash 'tfvars'
            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: awsCredentialsId]]) {
                sh "terraform init -reconfigure -backend-config=bucket=${bucketname}"
                sh "terraform workspace select ${name}"
                def destroyOutput = sh(script: "terraform destroy -auto-approve -var-file=terraform.tfvars -var='name=${name}'", returnStdout: true).trim()
                echo destroyOutput
                if (destroyOutput.contains("No changes. Infrastructure is up-to-date.") || destroyOutput.contains("Destroy complete! Resources: 0 destroyed.")) {
                    error("No resources to destroy")
                }
            }
        }
    }
}
