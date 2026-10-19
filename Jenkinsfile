pipeline {
    agent any

    environment {
        AWS_REGION     = 'us-east-1' // Change to your AWS region
        ECR_REGISTRY   = '956646644379.dkr.ecr.us-east-1.amazonaws.com' // Your ECR registry ID from earlier logs
        REPOSITORY_NAME = 'devops-capstone-app'
        IMAGE_TAG      = "${BUILD_NUMBER}"
        EKS_CLUSTER_NAME = 'devops-capstone-cluster'
    }

    stages {
        // 1. Pull the code from GitHub
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        // 2. Build the Docker image
        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${ECR_REGISTRY}/${REPOSITORY_NAME}:${IMAGE_TAG} -t ${ECR_REGISTRY}/${REPOSITORY_NAME}:latest ."
                }
            }
        }

        // 3. Authenticate with AWS ECR and push the image
        stage('Push to ECR') {
            steps {
                withCredentials([aws(credentialsId: 'aws-credentials', regionName: env.AWS_REGION)]) {
                    script {
                        sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"
                        sh "docker push ${ECR_REGISTRY}/${REPOSITORY_NAME}:${IMAGE_TAG}"
                        sh "docker push ${ECR_REGISTRY}/${REPOSITORY_NAME}:latest"
                    }
                }
            }
        }

        // 4. Deploy to AWS EKS using kubectl
        stage('Deploy to EKS') {
            steps {
                withCredentials([aws(credentialsId: 'aws-credentials')]) {
                    script {
                        sh "aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER_NAME}"
                        // This applies your deployment.yaml directly from your repo workspace
                        sh "kubectl apply -f k8s/deployment.yaml"
                        // This ensures the deployment rolls out with your new tag
                        sh "kubectl set image deployment/my-flask-app devops-capstone-app=${ECR_REGISTRY}/${REPOSITORY_NAME}:${IMAGE_TAG}"
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully! App deployed to EKS."
        }
        failure {
            echo "Pipeline failed. Check logs for details."
        }
    }
}