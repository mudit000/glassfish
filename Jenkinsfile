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
  stages {
    stage('glassfish-build') {
      agent {
        kubernetes {
          label 'mypod-A'
        }
      }
      steps {
        container('maven') {
          sh 'ci/build-tools/glassfish/gfbuild.sh build_re_dev 2>&1 && ls -l && ls -l bundles'
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
              sh 'mvn --version && ls -l bundles && appserver/tests/quicklook/run_test.sh ql_gf_full_profile_all'
              archiveArtifacts artifacts: 'results/'
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
              sh 'mvn --version && ls -l bundles && appserver/tests/quicklook/run_test.sh ql_gf_web_profile_all'
              archiveArtifacts artifacts: 'results/'
            }
          }
        }
      }
    }
  }
}