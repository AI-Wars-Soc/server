pipeline {
  agent any
  stages {
    stage('Build Docs') {
      steps {
        sh 'docker run --rm -it --name dcv -v ${PWD}:/input pmsipilot/docker-compose-viz render -m image --override=docker-compose.release.yml --output-file=architecture.png -r --force docker-compose.yml'
      }
    }
  }
}