pipeline {
    agent {
        docker {
            image 'node:16'  // Use Node 16 as build agent
            args '-v /var/run/docker.sock:/var/run/docker.sock --network project2-compose_jenkins'  // Connect to DinD network and socket
        }
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
        stage('Security Scan') {
            steps {
                sh '''
			wget https://github.com/dependency-check/DependencyCheck/releases/download/v12.1.5/dependency-check-12.1.5-release.zip
          unzip dependency-check-12.1.5-release.zip
          dependency-check/bin/dependency-check.sh --scan . --format HTML --out dep-check-report.html --failOnCVSS 7
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
            archiveArtifacts artifacts: '**/*'
        }
    }
}
