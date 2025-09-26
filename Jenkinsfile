pipeline {
    agent {
        docker { image 'node:16' }  // Use Node 16 as build agent per requirements
    }
    stages {
        stage('Install Dependencies') {
            steps {
                sh 'npm install --save'
            }
        }
        stage('Run Tests') {
            steps {
                sh 'npm test'
            }
        }
        stage('Install Java') {
            steps {
                sh '''
                    echo "Updating apt sources..."
                    sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list
                    sed -i 's/security.debian.org/archive.debian.org/g' /etc/apt/sources.list
                    apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || { echo "apt-get update failed"; exit 1; }
                    apt-get install -y default-jre-headless || { echo "Java installation failed"; exit 1; }
                    echo "Java installed, checking version: $(java -version 2>&1)"
                '''
            }
        }
        stage('Security Scan') {
            steps {
                sh '''
                    echo "Starting security scan with v11.0.0..."
                    wget https://github.com/dependency-check/DependencyCheck/releases/download/v11.0.0/dependency-check-11.0.0-release.zip
                    unzip -o dependency-check-11.0.0-release.zip
                    export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-arm64
                    export PATH=$JAVA_HOME/bin:$PATH
                    echo "JAVA_HOME is $JAVA_HOME, PATH is $PATH"
                    java -version
                    dependency-check/bin/dependency-check.sh --scan . --format HTML --out dep-check-report.html --failOnCVSS 7 || { echo "Scan failed"; exit 1; }
                '''
            }
        }
        stage('Install Docker') {
            steps {
                sh '''
                    echo "Updating apt sources for Docker..."
                    sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list
                    sed -i 's/security.debian.org/archive.debian.org/g' /etc/apt/sources.list
                    apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || { echo "apt-get update failed"; exit 1; }
                    apt-get install -y ca-certificates curl gnupg lsb-release || { echo "Prerequisites failed"; exit 1; }
                    mkdir -p /etc/apt/keyrings
                    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
                    echo "deb [signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian buster stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
                    apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false || { echo "apt-get update failed"; exit 1; }
                    apt-get install -y docker-ce docker-ce-cli containerd.io || { echo "Docker installation failed"; exit 1; }
                    echo "Docker installed successfully"
                '''
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t bibekdaii/my-node-app:latest .'
            }
        }
        stage('Push to Registry') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                    sh 'docker push bibekdaii/my-node-app:latest'
                }
            }
        }
    }
    post {
        always {
            archiveArtifacts artifacts: 'dep-check-report.html'
        }
    }
}
