pipeline{
    environment{
        IMAGE_TAG = "${BUILD_TAG}"
        USERNAME = "26021973"
        REPO_GIT = "https://github.com/steissier/devops-project3.git"
        IMG_NAME_WEBAPP = "img_webapp"
        CONTAINTER_NAME_DB = "postgres"
        CONTAINTER_NAME_WEB = "webapp"
    }
    agent any

    stages {
        stage ('Récupération repo Git') {
            agent {
                label 'agent1'
            }
            steps {
                script {
                    sh '''
                        rm -r test || true
                        mkdir test
                        cd test
                        git clone ${REPO_GIT}
                        cat devops-project3/entry_point.sh | grep -iq "#!/bin/bash"
                    '''
                }
            }
        }
        stage ('Build du conteneur & lancement application') {
            agent {
                label 'agent1'
            }
            steps {
                script {
                    sh '''
                        cd test/devops-project3
                        docker-compose up -d
                        sleep 5
                        curl http://localhost:8000/admin/login/ | grep -iq Log
                    '''
                }
            }
        }
        stage ('Push image') {
            agent {
                label 'agent1'
            }
            environment {
                PASSWORD=credentials('docker_pswd')
            }
            steps {
                script {
                    sh '''
                        docker-compose down
                        docker tag ${IMG_NAME_WEBAPP} ${USERNAME}/${IMG_NAME_WEBAPP}:${IMAGE_TAG}
                        docker login -u ${USERNAME} -p ${PASSWORD}
                        docker push ${USERNAME}/${IMG_NAME_WEBAPP}:${IMAGE_TAG}
                        docker rmi ${USERNAME}/${IMG_NAME_WEBAPP}:${IMAGE_TAG}
                    '''

                }
            }
        }
    }
}
    