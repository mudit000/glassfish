def jobs = ["JobA", "JobB", "JobC"]

def parallelStagesMap = jobs.collectEntries {
    ["${it}" : generateStage(it)]
}

def generateStage(job) {
    return {
        stage("stage: ${job}") {
                echo "This is ${job}."
                sh script: "sleep 500"
        }
    }
}

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
  - name: glassfish-ci
    image: arindamb/glassfish-ci
    command:
    - cat
    tty: true
"""
    }
  }

    stages {
        stage('non-parallel stage') {
            steps {
                echo 'This stage will be executed first.'
            }
        }

        stage('parallel stage') {
            agent {
            kubernetes {
              label 'mypod-A'
            }
          }
            steps {
                script {
                    parallel parallelStagesMap
                }
            }
        }
    }
}