build:
	docker build --build-arg JENKINS_CONFIG_CASC=https://github.com/Continuous-X/jenkins-cx-config-demo-project/blob/master/master/jenkins.yaml --no-cache --pull -t continuous-x/jenkins-cx:latest .
    docker build --build-arg JENKINS_CONFIG_CASC=https://github.com/Continuous-X/jenkins-cx-config-demo-project/blob/master/master/jenkins.yaml --no-cache --pull -t continuous-x/jenkins-cx:latest-alpine -f Dockerfile-alpine.dockerfile .

run:
	docker run --rm --name ci-jenkins-io-dev -v maven-repo:/root/.m2 -v ${MY_PIPELINE_LIBRARY_DIR}:/var/jenkins_home/pipeline-library -v ${MY_OTHER_PIPELINE_LIBS_DIRS}:/var/jenkins_home/pipeline-libs -e DEV_HOST=${CURRENT_HOST} -p 8080:8080 -p 50000:50000  continuous-x/jenkins-cx
	docker run -p 8080:8080 -p 50000:50000  continuous-x/jenkins-cx:latest
	docker run -p 80:8080 -p 50000:50000 continuous-x/jenkins-cx:latest-alpine
	docker run -e JENKINS_CONFIG_ALLOW_RUNS_ON_MASTER=true -p 80:8080 -p 50000:50000 continuous-x/jenkins-cx:latest-alpine

debug:
	docker run --rm --name ci-jenkins-io-dev -e DEBUG=true -p 5005:5005 -v maven-repo:/root/.m2 -v ${MY_PIPELINE_LIBRARY_DIR}:/var/jenkins_home/pipeline-library -v ${MY_OTHER_PIPELINE_LIBS_DIRS}:/var/jenkins_home/pipeline-libs -e DEV_HOST=${CURRENT_HOST} -p 8080:8080 -p 50000:50000  continuous-x/jenkins-cx
