#!/bin/bash

# Step 1: Run Terraform to provision the infrastructure
echo "Initializing and applying Terraform..."
cd terraform
terraform init
terraform apply -auto-approve
if [ $? -ne 0 ]; then
    echo "Terraform failed. Exiting."
    exit 1
fi
cd ..

# Step 2: Install Jenkins in Kubernetes
echo "Installing Jenkins in Kubernetes..."
kubectl create namespace jenkins
kubectl apply -f jenkins-deployment.yaml
echo "Waiting for Jenkins to be ready..."
sleep 120  # Adjust this based on your cluster's startup time

# Get Jenkins LoadBalancer URL
JENKINS_URL=$(kubectl get svc jenkins -n jenkins -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Jenkins is available at: http://$JENKINS_URL:8080"

# Step 3: Set up Jenkins pipeline for the weather app
echo "Configuring Jenkins pipeline..."
JENKINS_PASSWORD=$(kubectl exec -n jenkins $(kubectl get pods -n jenkins -l app=jenkins -o jsonpath='{.items[0].metadata.name}') -- cat /var/jenkins_home/secrets/initialAdminPassword)
echo "Jenkins admin password: $JENKINS_PASSWORD"

# Install Jenkins CLI
wget http://$JENKINS_URL/jnlpJars/jenkins-cli.jar

# Create Jenkins Pipeline Job
cat <<EOF > weather-pipeline.xml
<flow-definition plugin="workflow-job">
  <description>Pipeline for deploying weather app</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps">
    <script>
      pipeline {
          agent any
          stages {
              stage('Clone Repository') {
                  steps {
                      git 'https://github.com/jollykyles/weather-app.git'
                  }
              }
              stage('Build Docker Image') {
                  steps {
                      sh 'docker build -t jollykyles/weather-service:latest .'
                      sh 'docker build -t jollykyles/weather-app:latest .'
                  }
              }
              stage('Push Docker Image') {
                  steps {
                      sh 'docker push jollykyles/weather-service:latest'
                      sh 'docker push jollykyles/weather-app:latest'
                  }
              }
              stage('Deploy to Kubernetes') {
                  steps {
                      sh 'kubectl apply -f microservices/weather-app-deployment.yaml'
                      sh 'kubectl apply -f microservices/weather-app-service.yaml'
                  }
              }
          }
      }
    </script>
    <sandbox>true</sandbox>
  </definition>
  <triggers/>
</flow-definition>
EOF

java -jar jenkins-cli.jar -s http://$JENKINS_URL:8080/ -auth admin:$JENKINS_PASSWORD create-job weather-pipeline < weather-pipeline.xml

# Step 4: Trigger the Jenkins pipeline
echo "Triggering Jenkins pipeline..."
java -jar jenkins-cli.jar -s http://$JENKINS_URL:8080/ -auth admin:$JENKINS_PASSWORD build weather-pipeline

# Cleanup
rm jenkins-cli.jar
rm weather-pipeline.xml

echo "Deployment complete!"