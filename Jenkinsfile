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
  environment {
    S1AS_HOME = "$WORKSPACE/glassfish5/glassfish"
    APS_HOME = "$WORKSPACE/appserver/tests/appserv-tests"
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
            container('glassfish-ci') {
              unstash 'build-bundles'
              sh 'appserver/tests/gftest.sh run_test ql_gf_full_profile_all'
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
            container('glassfish-ci') {
              unstash 'build-bundles'
              sh 'appserver/tests/gftest.sh run_test ql_gf_web_profile_all'
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
            container('glassfish-ci') {
              unstash 'build-bundles'
              sh 'appserver/tests/gftest.sh run_test deployment_all'
              archiveArtifacts artifacts: 'deployment_all-results.tar.gz'
              junit 'results/junitreports/*.xml'
            }
          }
        }
        stage('quicklook-embedded') {
          agent {
            kubernetes {
              label 'mypod-A'
            }
          }
          steps {
            container('glassfish-ci') {
              unstash 'build-bundles'
              sh 'appserver/tests/gftest.sh run_test ql_gf_embedded_profile_all'
              archiveArtifacts artifacts: 'ql_gf_embedded_profile_all-results.tar.gz'
              junit 'results/junitreports/*.xml'
            }
          }
        }
        stage('quicklook-nucleus') {
          agent {
            kubernetes {
              label 'mypod-A'
            }
          }
          steps {
            container('glassfish-ci') {
              unstash 'build-bundles'
              sh 'appserver/tests/gftest.sh run_test ql_gf_nucleus_all'
              archiveArtifacts artifacts: 'gf_nucleus_all-results.tar.gz'
              junit 'results/junitreports/*.xml'
            }
          }
        }
        stage('quicklook-nucleus-admin') {
          agent {
            kubernetes {
              label 'mypod-A'
            }
          }
          steps {
            container('glassfish-ci') {
              unstash 'build-bundles'
              sh 'appserver/tests/gftest.sh run_test nucleus_admin_all'
              archiveArtifacts artifacts: 'nucleus_admin_all-results.tar.gz'
              junit 'results/junitreports/*.xml'
            }
          }
        }
        stage('deployment-cluster') {
          agent {
            kubernetes {
              label 'mypod-A'
            }
          }
          steps {
            container('glassfish-ci') {
              unstash 'build-bundles'
              sh 'appserver/tests/gftest.sh run_test deployment_cluster_all'
              archiveArtifacts artifacts: 'deployment_cluster_all-results.tar.gz'
              junit 'results/junitreports/*.xml'
            }
          }
        }
      }
    }
  }
}