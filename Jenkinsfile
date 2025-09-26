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
                  sed -i "s/deb.debian.org/archive.debian.org/g" /etc/apt/sources.list
                  sed -i "s/security.debian.org/archive.debian.org/g" /etc/apt/sources.list
                  sed -i "s/deb [arch=/deb [ signed-by=/g" /etc/apt/sources.list
                  apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false
                  apt-get install -y default-jre-headless
                '''
            }
        }
        stage('Security Scan') {
            steps {
                sh '''
                  wget https://github.com/dependency-check/DependencyCheck/releases/download/v12.1.0/dependency-check-12.1.0-release.zip
                  unzip -o dependency-check-12.1.0-release.zip
                  dependency-check/bin/dependency-check.sh --scan . --format HTML --out dep-check-report.html --failOnCVSS 7
                '''
            }
        }
        stage('Install Docker') {
            steps {
                sh '''
                  sed -i "s/deb.debian.org/archive.debian.org/g" /etc/apt/sources.list
                  sed -i "s/security.debian.org/archive.debian.org/g" /etc/apt/sources.list
                  sed -i "s/deb [arch=/deb [ signed-by=/g" /etc/apt/sources.list
                  apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false
                  apt-get install -y ca-certificates curl gnupg lsb-release
                  mkdir -p /etc/apt/keyrings
                  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
                  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian buster stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
                  apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false
                  apt-get install -y docker-ce docker-ce-cli containerd.io
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
