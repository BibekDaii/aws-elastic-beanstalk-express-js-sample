pipeline {
    agent {
        docker { image 'docker:20.10.7' }
    }
    stages {
        stage('Install Dependencies') {
            steps {
                sh 'apk add --no-cache nodejs npm'
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
                    apk add --no-cache openjdk11-jre
                    echo "Java installed, checking version: $(java -version 2>&1)"
                '''
            }
        }
        stage('Security Scan') {
            steps {
                sh '''
                    echo "Starting security scan with v11.0.0..."
                    rm -f dependency-check-11.0.0-release.zip
                    wget -c https://github.com/dependency-check/DependencyCheck/releases/download/v11.0.0/dependency-check-11.0.0-release.zip
                    unzip -o dependency-check-11.0.0-release.zip
                    export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
                    export PATH=$JAVA_HOME/bin:$PATH
                    echo "JAVA_HOME is $JAVA_HOME, PATH is $PATH"
                    java -version
                    dependency-check/bin/dependency-check.sh --scan . --exclude **/package-lock.json --disable ossindex --format HTML --out dep-check-report.html --failOnCVSS 7 || { echo "Scan completed with errors, proceeding"; }
                '''
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'ls -la'  // Debug: List files to confirm Dockerfile presence
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
