pipeline{
    agent any
    
    stages{
        stage("Code clone"){
            steps{
                echo "cloning code"
                git url:"https://github.com/alokkumarM/django-notes-app.git", branch:"main"
            }
        }
        stage("Code Build"){
            steps{
            echo "building docker image"
            sh "docker build -t jen-notes ." 
            }
        }
        stage("Push to DockerHub"){
            steps{
                echo "image push to docker hub"
                withCredentials([usernamePassword(credentialsId:"dockerhub",passwordVariable:"dockerhubPass",usernameVariable:"dockerhubUser")]){
                sh "docker tag jen-notes ${env.dockerhubUser}/jen-notes:latest"
                sh "docker login -u ${env.dockerhubUser} -p ${env.dockerhubPass}"
                sh "docker push ${env.dockerhubUser}/jen-notes:latest"
                }
                
            }
        }
        stage("Deploy"){
            steps{
                echo "deploying "
                withCredentials([usernamePassword(credentialsId:"dockerhub",passwordVariable:"dockerhubPass",usernameVariable:"dockerhubUser")]){
                    sh "docker network create notes || true"
                    sh "docker rm -f mysql || true"
                    sh "docker run -d --name mysql --network notes -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=notes -v mysql-data:/var/lib/mysql mysql"
                    sh '''
                    until docker exec mysql mysqladmin ping -h localhost -uroot -proot --silent; do
                    echo "Waiting for MySQL..."
                    sleep 5
                    done
                    '''
                    sh "docker rm -f jen-app || true"
                    sh "docker pull ${dockerhubUser}/jen-notes:latest"
                    sh "docker run --rm --network notes --env-file .env ${dockerhubUser}/jen-notes:latest python manage.py migrate"
                    sh "docker run -d --name jen-app --network notes --env-file .env -p 8000:8000 ${dockerhubUser}/jen-notes:latest"
                }
            }
        }
        
    }
}
