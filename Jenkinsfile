def jobs = ["ql_gf_full_profile_all", "ql_gf_web_profile_all", "ql_gf_nucleus_all", "ql_gf_embedded_profile_all", "nucleus_admin_all", "deployment_all"]

def parallelStagesMap = jobs.collectEntries {
  ["${it}": generateStage(it)]
}

def generateStage(job) {
    return {
        def label = "mypod-A"
        podTemplate(label: label) {
            node(label) {
                stage("${job}") {
                    container('glassfish-ci') {
                      unstash 'build-bundles'
                      sh "$WORKSPACE/bundles/gftest.sh run_test ${job}"
                      archiveArtifacts artifacts: "${job}-results.tar.gz"
                      junit 'results/junitreports/*.xml'
                    }
                }
            }
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
    imagePullPolicy: Always
"""
    }
  }
  environment {
    S1AS_HOME = "$WORKSPACE/glassfish5/glassfish"
    APS_HOME = "$WORKSPACE/main/appserver/tests/appserv-tests"
    TEST_RUN_LOG = "$WORKSPACE/tests-run.log"
    MAVEN_REPO_LOCAL = "$WORKSPACE/repository"
  }
  stages {
    stage('glassfish-build') {
      agent {
        kubernetes {
          label 'mypod-A'
        }
      }
      steps {
        container('glassfish-ci') {
          sh 'ci/build-tools/glassfish/gfbuild.sh build_re_dev 2>&1'
          archiveArtifacts artifacts: 'bundles/*.zip'
          junit '**/surefire-reports/*.xml'
          stash includes: 'bundles/*', name: 'build-bundles'
        }
      }
    }
    stage('glassfish-tests') {
      steps {
        script {
          parallel parallelStagesMap
        }
      }
    }
  }
}