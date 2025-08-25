@Library('team-shared-lib') _

pipeline {
    agent { label 'docker' } 

    tools {
    jdk   'jdk-17.0.16'
    maven 'Maven-3.9.11'
    }


    options {
        timestamps()
        ansiColor('xterm')
        skipDefaultCheckout(true)
    }

    parameters {
        choice(name: 'ENV', choices: ['dev', 'staging', 'prod'], description: 'Target environment')
        string(name: 'REGISTRY',    defaultValue: 'docker.io',        description: 'Docker registry host')
        string(name: 'DOCKER_REPO', defaultValue: 'mohamedemad_java-app', description: 'Docker repository path')
        string(name: 'IMAGE_TAG',   defaultValue: '', description: 'Optional; empty => <branch>-<build_number>')
        booleanParam(name: 'SKIP_TESTS', defaultValue: false, description: 'Skip unit tests?')
        string(name: 'REPLICAS', defaultValue: '3', description: 'Demo for sharedlib bounds() (1..5)')
    }

    stages {

        stage('Init & Checkout') {
            steps {
                checkout scm
                stash name: 'src', includes: '**/*', useDefaultExcludes: false
                script {
                    env.BRANCH_SLUG = env.BRANCH_NAME?.replaceAll('/', '-') ?: 'main'
                    env.EFFECTIVE_TAG = params.IMAGE_TAG?.trim() ?: "${env.BRANCH_SLUG}-${env.BUILD_NUMBER}"
                    env.REPLICAS_BOUNDED = bounds(value: params.REPLICAS as int, min: 1, max: 5) as String

                    echo "ENV           : ${params.ENV}"
                    echo "IMAGE TAG     : ${env.EFFECTIVE_TAG}"
                    echo "Replicas (raw): ${params.REPLICAS} -> bounded: ${env.REPLICAS_BOUNDED}"
                }
            }
        }

        stage('Quality (parallel)') {
            parallel {
                stage('Compile only') {
                    steps {
                        dir('compile') {
                            unstash 'src'
                            bat 'mvn -B -DskipTests=true clean compile'
                        }
                    }
                }
                stage('Unit tests') {
                    steps {
                        dir('tests') {
                            unstash 'src'
                            bat 'mvn -B -DskipTests=false test'
                            junit allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml'
                        }
                    }
                }
            }
        }

        stage('Build JAR') {
            steps {
                bat "mvn -B -DskipTests=${params.SKIP_TESTS} clean package"
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('Build Docker image') {
            steps {
                bat """
                  docker build --build-arg APP_ENV=%ENV% -t %REGISTRY%/%DOCKER_REPO%:%EFFECTIVE_TAG% .
                """
            }
        }

        stage('Docker login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred',
                                                  usernameVariable: 'DOCKER_USER',
                                                  passwordVariable: 'DOCKER_PASS')]) {
                    bat 'docker login -u %DOCKER_USER% -p %DOCKER_PASS% %REGISTRY%'
                }
            }
        }

        stage('Push Docker image') {
            steps {
                bat "docker push %REGISTRY%/%mohamedemad_java-app%:%EFFECTIVE_TAG%"
            }
        }
    }

    post {
        always {
            bat "docker logout %REGISTRY% || exit 0"
            bat "docker image prune -f || exit 0"
            bat "docker rmi %REGISTRY%/%DOCKER_REPO%:%EFFECTIVE_TAG% || exit 0"
            cleanWs()
        }
    }
}
