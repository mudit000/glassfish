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
    some-label: some-label-value
spec:
  containers:
  - name: maven
    image: maven
    command:
    - cat
    tty: true
  - name: busybox
    image: busybox
    command:
    - cat
    tty: true
"""
    }
  }
  stages {
    stage('glassfish-build') {
      agent {
        kubernetes {
          label 'mypod-A'
        }
      }
      steps {
        container('maven') {
          sh 'mvn --version && mvn -DproxySet=true -DproxyHost=www-proxy.us.oracle.com -DproxyPort=80 clean install && ls -l appserver/distributions/glassfish/target/*.zip && ls -l appserver/distributions/web/target/*.zip && ls -l nucleus/distributions/nucleus/target/*.zip'
          stash includes: 'appserver/distributions/glassfish/target/*.zip,appserver/distributions/web/target/*.zip,nucleus/distributions/nucleus/target/*.zip', name: 'build-bundles'
        }
      }
    }
    stage('glassfish-functional-tests') {
      parallel {
        stage('quicklook') {
            agent {
              kubernetes {
                label 'mypod-A'
              }
            }
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