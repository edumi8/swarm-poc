pipeline {
    agent any
    
    environment {
        VERSION = "${env.BUILD_NUMBER}"
        REGISTRY = credentials('docker-registry')  // Configure in Jenkins
        DEV_SWARM = credentials('dev-swarm-manager')
        STAGE_SWARM = credentials('stage-swarm-manager')
        PROD_SWARM = credentials('prod-swarm-manager')
    }
    
    stages {
        stage('Build Services') {
            parallel {
                stage('Build Service A') {
                    steps {
                        dir('services/service-a') {
                            sh 'docker build -t ${REGISTRY}/service-a:${VERSION} .'
                            sh 'docker tag ${REGISTRY}/service-a:${VERSION} ${REGISTRY}/service-a:latest'
                        }
                    }
                }
                stage('Build Service B') {
                    steps {
                        dir('services/service-b') {
                            sh 'docker build -t ${REGISTRY}/service-b:${VERSION} .'
                            sh 'docker tag ${REGISTRY}/service-b:${VERSION} ${REGISTRY}/service-b:latest'
                        }
                    }
                }
                stage('Build Service C') {
                    steps {
                        dir('services/service-c') {
                            sh 'docker build -t ${REGISTRY}/service-c:${VERSION} .'
                            sh 'docker tag ${REGISTRY}/service-c:${VERSION} ${REGISTRY}/service-c:latest'
                        }
                    }
                }
            }
        }
        
        stage('Push Images') {
            steps {
                script {
                    sh '''
                        docker push ${REGISTRY}/service-a:${VERSION}
                        docker push ${REGISTRY}/service-a:latest
                        docker push ${REGISTRY}/service-b:${VERSION}
                        docker push ${REGISTRY}/service-b:latest
                        docker push ${REGISTRY}/service-c:${VERSION}
                        docker push ${REGISTRY}/service-c:latest
                    '''
                }
            }
        }
        
        stage('Deploy to Dev') {
            steps {
                script {
                    sh '''
                        scp swarm/dev.yml ${DEV_SWARM}:/tmp/dev.yml
                        ssh ${DEV_SWARM} "VERSION=${VERSION} docker stack deploy -c /tmp/dev.yml dev"
                    '''
                }
            }
        }
        
        stage('Verify Dev Deployment') {
            steps {
                script {
                    sh '''
                        sleep 30
                        ssh ${DEV_SWARM} "docker service ls --filter name=dev"
                    '''
                }
            }
        }
        
        stage('Deploy to Stage') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to Stage?', ok: 'Deploy'
                script {
                    sh '''
                        scp swarm/stage.yml ${STAGE_SWARM}:/tmp/stage.yml
                        ssh ${STAGE_SWARM} "VERSION=${VERSION} docker stack deploy -c /tmp/stage.yml stage"
                    '''
                }
            }
        }
        
        stage('Verify Stage Deployment') {
            when {
                branch 'main'
            }
            steps {
                script {
                    sh '''
                        sleep 30
                        ssh ${STAGE_SWARM} "docker service ls --filter name=stage"
                    '''
                }
            }
        }
        
        stage('Deploy to Prod') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to Production? This will deploy with ZERO DOWNTIME', ok: 'Deploy to Prod'
                script {
                    sh '''
                        scp swarm/prod.yml ${PROD_SWARM}:/tmp/prod.yml
                        ssh ${PROD_SWARM} "VERSION=${VERSION} docker stack deploy -c /tmp/prod.yml prod"
                    '''
                }
            }
        }
        
        stage('Verify Prod Deployment') {
            when {
                branch 'main'
            }
            steps {
                script {
                    sh '''
                        sleep 60
                        ssh ${PROD_SWARM} "docker service ls --filter name=prod"
                        echo "Checking service health..."
                        for i in 1 2 3; do
                            ssh ${PROD_SWARM} "docker service ps prod_service-a-prod --filter 'desired-state=running'"
                            ssh ${PROD_SWARM} "docker service ps prod_service-b-prod --filter 'desired-state=running'"
                            ssh ${PROD_SWARM} "docker service ps prod_service-c-prod --filter 'desired-state=running'"
                            sleep 10
                        done
                    '''
                }
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completed successfully!'
            echo "Deployed version: ${VERSION}"
        }
        failure {
            echo 'Pipeline failed!'
            echo 'Check rollback if necessary'
        }
    }
}
