@Library('Shared') _

pipeline {
    agent any
    
    environment {
        // Update the main app image name to match the deployment file
        DOCKER_IMAGE_NAME = 'yash12j/easyshop-app'
        DOCKER_MIGRATION_IMAGE_NAME = 'yash12j/easyshop-migration'
        DOCKER_IMAGE_TAG = "${BUILD_NUMBER}"
        // GITHUB_CREDENTIALS = credentials('github-credentials')
        GIT_BRANCH = "master"
    }
    
    stages {
        stage('Cleanup Workspace') {
            steps {
                script {
                    clean_ws()
                }
            }
        }
        
stage('Checkout') {
    environment {
        GITHUB_CREDENTIALS = credentials('github-credentials')
    }
    steps {
        git branch: "${GIT_BRANCH}",
            url: "https://${env.GITHUB_CREDENTIALS}@github.com/codeBuilt864/DevopsProject_tws_e-commerce.git"
    }
}


        
        stage('Build Docker Images') {
            parallel {
                stage('Build Main App Image') {
                    steps {
                        script {
                            docker_build(
                                imageName: env.DOCKER_IMAGE_NAME,
                                imageTag: env.DOCKER_IMAGE_TAG,
                                dockerfile: 'Dockerfile',
                                context: '.'
                            )
                        }
                    }
                }
                
                stage('Build Migration Image') {
                    steps {
                        script {
                            docker_build(
                                imageName: env.DOCKER_MIGRATION_IMAGE_NAME,
                                imageTag: env.DOCKER_IMAGE_TAG,
                                dockerfile: 'scripts/Dockerfile.migration',
                                context: '.'
                            )
                        }
                    }
                }
            }
        }
        
        stage('Run Unit Tests') {
            steps {
                script {
                    run_tests()
                }
            }
        }
        
        stage('Security Scan with Trivy') {
            steps {
                script {
                    // Create directory for results
                  
                    trivy_scan()
                    
                }
            }
        }
        
        stage('Push Docker Images') {
            parallel {
                stage('Push Main App Image') {
                    steps {
                        script {
                            docker_push(
                                imageName: env.DOCKER_IMAGE_NAME,
                                imageTag: env.DOCKER_IMAGE_TAG,
                                credentials: 'docker-hub-credentials'
                            )
                        }
                    }
                }
                
                stage('Push Migration Image') {
                    steps {
                        script {
                            docker_push(
                                imageName: env.DOCKER_MIGRATION_IMAGE_NAME,
                                imageTag: env.DOCKER_IMAGE_TAG,
                                credentials: 'docker-hub-credentials'
                            )
                        }
                    }
                }
            }
        }
        
        // Add this new stage
        stage('Update Kubernetes Manifests') {
            steps {
                script {
                    update_k8s_manifests(
                        imageTag: env.DOCKER_IMAGE_TAG,
                        manifestsPath: 'kubernetes',
                        gitCredentials: 'github-credentials',
                        gitUserName: 'Jenkins CI',
                        gitUserEmail: 'yaseerbostbox@gmail.com'
                    )
                }
            }
        }
    }
}


        def call(Map args) {
    withCredentials([string(credentialsId: args.gitCredentials, variable: 'GITHUB_TOKEN')]) {
        sh """
            git config --global user.email '${args.gitUserEmail}'
            git config --global user.name '${args.gitUserName}'
            git pull
            git commit -am "Update manifests"
            git push https://${GITHUB_TOKEN}@github.com/codeBuilt864/DevopsProject_tws_e-commerce.git HEAD:main
        """
    }
}
