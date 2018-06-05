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
    stage('build') {
      steps {
        echo 'from build'
        sh 'pwd && ls -al'
      }
    }
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
  }
}
