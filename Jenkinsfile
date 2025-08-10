@Library('Shared') _

pipeline {
    agent any

    options {
        disableConcurrentBuilds()
        timeout(time: 30, unit: 'MINUTES') // Prevent infinite runs
    }

    environment {
        DOCKER_IMAGE_NAME = 'yash12j/easyshop-app'
        DOCKER_MIGRATION_IMAGE_NAME = 'yash12j/easyshop-migration'
        DOCKER_IMAGE_TAG = "${BUILD_NUMBER}"
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
                timeout(time: 2, unit: 'MINUTES') {
                    git branch: "${GIT_BRANCH}",
                        url: "https://${env.GITHUB_CREDENTIALS}@github.com/codeBuilt864/DevopsProject_tws_e-commerce.git"
                }
            }
        }

        stage('Build Docker Images') {
            parallel {
                stage('Build Main App Image') {
                    steps {
                        timeout(time: 10, unit: 'MINUTES') {
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
                }

                stage('Build Migration Image') {
                    steps {
                        timeout(time: 10, unit: 'MINUTES') {
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
        }

        stage('Run Unit Tests') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    script {
                        run_tests()
                    }
                }
            }
        }

        stage('Security Scan with Trivy') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    script {
                        trivy_scan()
                    }
                }
            }
        }

        stage('Push Docker Images') {
            parallel {
                stage('Push Main App Image') {
                    steps {
                        timeout(time: 10, unit: 'MINUTES') {
                            script {
                                docker_push(
                                    imageName: env.DOCKER_IMAGE_NAME,
                                    imageTag: env.DOCKER_IMAGE_TAG,
                                    credentials: 'dockerHup-credencial'
                                )
                            }
                        }
                    }
                }

                stage('Push Migration Image') {
                    steps {
                        timeout(time: 10, unit: 'MINUTES') {
                            script {
                                docker_push(
                                    imageName: env.DOCKER_MIGRATION_IMAGE_NAME,
                                    imageTag: env.DOCKER_IMAGE_TAG,
                                    credentials: 'dockerHup-credencial'
                                )
                            }
                        }
                    }
                }
            }
        }

        stage('Update Kubernetes Manifests') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    withCredentials([usernamePassword(credentialsId: 'codeBuilt864', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        script {
                            update_k8s_manifests(
                                imageTag: env.DOCKER_IMAGE_TAG,
                                manifestsPath: 'kubernetes',
                                gitCredentials: "${USERNAME}:${PASSWORD}".toString(),
                                gitUserName: 'Jenkins CI',
                                gitUserEmail: 'yaseerbostbox@gmail.com'
                            )
                        }
                    }
                }
            }
        }
    }
}
