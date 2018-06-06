pipeline {
  agent {
    kubernetes {
      //cloud 'kubernetes'
      label 'mypod'
      containerTemplate {
        name 'maven'
        image 'maven:3.3.9-jdk-8-alpine'
        ttyEnabled true
        command 'cat'
      }
    }
  }
  stages {
    stage('stage 1') {
      parallel {
        stage('stage1.1') {
          agent {
            kubernetes {
              label 'mypod-A'
              containerTemplate {
                name 'busybox'
                image 'busybox:latest'
                ttyEnabled true
                command 'cat'
              }
            }
          }
          steps {
            container('busybox') {
              echo 'from Stage1.1'
              sh 'echo "stage1.1" > output.txt'
              stash includes: 'output.txt', name: 'stash-stage1.1'
            }
          }
        }
        stage('stage 1.2') {
          agent {
            kubernetes {
              label 'mypod-B'
              containerTemplate {
                name 'busybox'
                image 'busybox:latest'
                ttyEnabled true
                command 'cat'
              }
            }
          }
          steps {
            container('busybox') {
              echo 'from Stage 1.2'
              sh 'echo "stage1.2" > output.txt'
              stash includes: 'output.txt', name: 'stash-stage1.2'
            }
          }
        }
        stage('stage 1.3') {
          agent {
            kubernetes {
              label 'mypod-C'
              containerTemplate {
                name 'busybox'
                image 'busybox:latest'
                ttyEnabled true
                command 'cat'
              }
            }
          }
          steps {
            container('busybox') {
              echo "from stage 1.3" 
            }
          }
        }
      }
    }
    stage('stage3') {
      steps {
        echo 'from stage3'
        dir('from-stage-1.1') {
          unstash 'stash-stage1.1'
          sh 'pwd && ls -al . && ls -al ../ && cat output.txt'
        }
        dir('from-stage-1.2') {
          unstash 'stash-stage1.2'
          sh 'pwd && ls -al . && ls -al ../ && cat output.txt'
        }
        archiveArtifacts artifacts: 'from-stage-*/**/*'
      }
    }
  }
}