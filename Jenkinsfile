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
          sh 'mvn --version && mvn clean install'
        }
      }
    }
  }
}
