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
  - name: maven
    image: maven
    command:
    - cat
    tty: true
"""
    }
  }
  stages {
    stage('glassfish-build') {
      steps {
        container('maven') {
          sh 'mvn --version && mvn -DproxySet=true -DproxyHost=www-proxy.us.oracle.com -DproxyPort=80 clean install'
          stash includes: 'appserver/distributions/glassfish/target/*.zip,appserver/distributions/web/target/*.zip,nucleus/distributions/nucleus/target/*.zip', name: 'build-bundles'
        }
      }
    }
    stage('glassfish-functional-tests') {
      parallel {
        stage('quicklook') {
          steps {
            container('maven') {
              unstash 'build-bundles'
              sh 'mvn --version && ls -al'
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
