pipeline {
 agent {
    kubernetes {
      label 'mypod'
      defaultContainer 'jnlp'
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    mypod: "ok"
spec:
  containers:
  - name: busybox
    image: busybox
    command:
    - cat
    tty: true
"""
    }
  }
  stages {
    stage('stage 1') {
      parallel {
        stage('stage1.1') {
          steps {
            container('busybox') {
              echo 'from Stage1.1'
              sh 'echo "stage1.1" > output.txt'
              stash includes: 'output.txt', name: 'stash-stage1.1'
            }
          }
        }
        stage('stage 1.2') {
          steps {
            container('busybox') {
              echo 'from Stage 1.2'
              sh 'echo "stage1.2" > output.txt'
              stash includes: 'output.txt', name: 'stash-stage1.2'
            }
          }
        }
        stage('stage 1.3') {
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
