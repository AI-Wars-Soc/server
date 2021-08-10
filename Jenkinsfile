pipeline {
  agent any
  stages {
    stage('Build Docs') {
      steps {
        sh 'docker run --rm --name dcv -v ${PWD}:/input pmsipilot/docker-compose-viz render -m image --override=docker-compose.release.yml --output-file=architecture.png -r --force docker-compose.yml'
      }
    }
  }
  
  

  post {
	always {
	  archiveArtifacts artifacts: 'architecture.png', fingerprint: true
	}
  }
}