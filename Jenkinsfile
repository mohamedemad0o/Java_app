pipeline {
    agent any
    tools {
        jdk 'jdk-17' 
    }
    environment {
        MAVEN_HOME = "F:\\ITI\\CI-CD\\day2\\apache-maven-3.9.11"
        PATH = "${env.MAVEN_HOME}\\bin;${env.PATH}"
        MAVEN_REPO_LOCAL = "C:\\Users\\HP\\.m2\\repository"
        DOCKER_IMAGE = "mohamedemad0o/mohamedemad_java-app"
        DOCKER_CREDENTIALS_ID = "docker-hub-creds"
    }
    stages {
        stage('Unit tests') {
            parallel {
                stage('Test with Maven') {
                    steps {
                        dir('C:\\ProgramData\\Jenkins\\.jenkins\\workspace\\java-app-pipeline_main') {
                            bat "${MAVEN_HOME}\\bin\\mvn clean test -Dmaven.repo.local=${MAVEN_REPO_LOCAL}"
                        }
                    }
                }
            }
        }

        stage('Build JAR') {
            steps {
                dir('C:\\ProgramData\\Jenkins\\.jenkins\\workspace\\java-app-pipeline_main') {
                    bat "${MAVEN_HOME}\\bin\\mvn clean package -Dmaven.repo.local=${MAVEN_REPO_LOCAL}"
                }
            }
        }

        stage('Build Docker image') {
            steps {
                bat "docker build -t ${DOCKER_IMAGE}:main ."
            }
        }

        stage('Docker login') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    bat "docker login -u %DOCKER_USER% -p %DOCKER_PASS%"
                }
            }
        }

        stage('Push Docker image') {
            steps {
                bat "docker push ${DOCKER_IMAGE}:main"
            }
        }
    }

    post {
        always {
            bat "docker logout || exit 0"
            bat "docker image prune -f || exit 0"
            cleanWs()
        }
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed. Check the logs above."
        }
    }
}