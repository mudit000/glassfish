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
  - name: ant
    image: frekele/ant:1.9.9-jdk8
    command:
    - cat
    tty: true
"""
    }
  }
  environment {
    S1AS_HOME = "$WORKSPACE/glassfish5/glassfish"
    APS_HOME = "$WORKSPACE/appserver/tests/appserv-tests"
    TEST_RUN_LOG = "tests-run.log"
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
        container('maven') {
          sh 'ci/build-tools/glassfish/gfbuild.sh build_re_dev 2>&1'
          archiveArtifacts artifacts: 'bundles/*.zip'
          junit '**/surefire-reports/*.xml'
          stash includes: 'bundles/*.zip', name: 'build-bundles'
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
              sh 'appserver/tests/quicklook/run_test.sh run_test_id ql_gf_full_profile_all'
              sh 'appserver/tests/quicklook/run_test.sh copy_ql_results ql_gf_full_profile_all'
              archiveArtifacts artifacts: 'ql_gf_full_profile_all-results.tar.gz'
              junit 'results/junitreports/*.xml'
            }
          }
        }
        stage('quicklook-web') {
          agent {
            kubernetes {
              label 'mypod-A'
            }
          }
          steps {
            container('maven') {
              unstash 'build-bundles'
              sh 'appserver/tests/quicklook/run_test.sh run_test_id ql_gf_web_profile_all'
              sh 'appserver/tests/quicklook/run_test.sh copy_ql_results ql_gf_web_profile_all'
              archiveArtifacts artifacts: 'ql_gf_web_profile_all-results.tar.gz'
              junit 'results/junitreports/*.xml'
            }
          }
        }
        stage('deployment') {
          agent {
            kubernetes {
              label 'mypod-A'
            }
          }
          steps {
            container('ant') {
              unstash 'build-bundles'
              sh 'appserver/tests/appserv-tests/devtests/deployment/run_test.sh run_test_id deployment_all'
              sh 'appserver/tests/quicklook/run_test.sh copy_test_artifects deployment_all'
              archiveArtifacts artifacts: 'deployment_all-results.tar.gz'
              junit 'results/junitreports/*.xml'
            }
          }
        }
      }
    }
  }
}