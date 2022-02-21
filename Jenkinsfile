pipeline{
    environment{
        IMAGE_TAG = "${BUILD_NUMBER}"
        ansibleServer = "172.31.93.196"
        stagingServer = "172.31.88.182"
        prodServer = "172.31.91.203"
        homeDirAnsible = "ansible_deploy"
        USERNAME = "26021973"
        REPO_GIT = "https://github.com/steissier/devops-project3.git"
        IMG_NAME_WEBAPP = "img_webapp"
        CONTAINTER_NAME_DB = "postgres"
        CONTAINTER_NAME_WEB = "webapp"
    }
    agent any

    stages {
        stage ('Build du conteneur & lancement application') {
            agent {
                label 'agent1'
            }
            steps {
                script {
                    sh '''
                        docker-compose down || true
                        docker-compose up -d
                        sleep 10
                        curl http://localhost:8000/ | tac | grep -iq Hello
                    '''
                }
            }
        }
        stage ('Test de securité') {
            agent {
                label 'agent1'
            }
            environment {
                SNYKKEY=credentials('snykKey')
            }
            steps {
                script {
                    sh '''
                        snyk auth ${SNYKKEY}
                        snyk container test ${IMG_NAME_WEBAPP} --severity-threshold=critical  > test_result.log || true
                    '''
                }
            }
        }
        stage ('Push image') {
            agent {
                label 'agent1'
            }
            environment {
                PASSWORD=credentials('dockerhubPswd')
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
        stage ('Deploy staging') {
            agent {
                label 'agent1'
            }
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: "ssh_connexion", keyFileVariable: 'keyfile', usernameVariable: 'sshuser')]) {
                    script {
                        sh '''
                            ssh -o StrictHostKeyChecking=no -i ${keyfile} ${sshuser}@${ansibleServer} -C ansible-playbook -i ${homeDirAnsible}/hosts.yml -e imgTag=${IMAGE_TAG} -e userName=${USERNAME} -e imgNameWebApp=${IMG_NAME_WEBAPP} ${homeDirAnsible}/main_staging.yml
                            sleep 10
                            curl ${stagingServer}:8000| tac | grep -iq Hello
                        '''
                    }
                }
            }
        }
        stage ('Deploy prod') {
            agent {
                label 'agent1'
            }
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: "ssh_connexion", keyFileVariable: 'keyfile', usernameVariable: 'sshuser')]) {
                    script {
                        sh '''
                            ssh -o StrictHostKeyChecking=no -i ${keyfile} ${sshuser}@${ansibleServer} -C ansible-playbook -i ${homeDirAnsible}/hosts.yml -e imgTag=${IMAGE_TAG} -e userName=${USERNAME} -e imgNameWebApp=${IMG_NAME_WEBAPP} ${homeDirAnsible}/main_prod.yml
                            sleep 10
                            curl ${prodServer}:8000 | tac | grep -iq Hello
                        '''
                    }
                }
            }
        }
    }
    post {
        always {
            script {
                if ( currentBuild.result == "SUCCESS" ) {
                    slackSend color: "good", message: "CONGRATULATION: Job ${env.JOB_NAME} with buildnumber ${env.BUILD_NUMBER} was successful ! more info ${env.BUILD_URL}"
                }
                else if( currentBuild.result == "FAILURE" ) { 
                    slackSend color: "danger", message: "BAD NEWS:Job ${env.JOB_NAME} with buildnumber ${env.BUILD_NUMBER} was failed ! more info ${env.BUILD_URL}"
                }
                else if( currentBuild.result == "UNSTABLE" ) { 
                    slackSend color: "warning", message: "BAD NEWS:Job ${env.JOB_NAME} with buildnumber ${env.BUILD_NUMBER} was unstable ! more info ${env.BUILD_URL}"
                }
                else {
                    slackSend color: "danger", message: "BAD NEWS:Job ${env.JOB_NAME} with buildnumber ${env.BUILD_NUMBER} its result was unclear ! more info ${env.BUILD_URL}"	
                }
            }
        }
    }
}
  