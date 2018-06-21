// list of test ids
def jobs = [
  "web_jsp",
  "web_servlet",
  "web_web-container",
  "web_group-1",
  "sqe_smoke_all",
  "security_all",
  "admin-cli-group-1",
  "admin-cli-group-2",
  "admin-cli-group-3",
  "admin-cli-group-4",
  "admin-cli-group-5",
  "deployment_all",
  "deployment_cluster_all",
  "ejb_group_1",
  "ejb_group_2",
  "ejb_group_3",
  "ejb_timer_cluster_all",
  "ejb_web_all",
  "transaction-ee-1",
  "transaction-ee-2",
  "transaction-ee-3",
  "transaction-ee-4",
  "cdi_all",
  "ql_gf_full_profile_all",
  "ql_gf_nucleus_all",
  "ql_gf_web_profile_all",
  "ql_gf_embedded_profile_all",
  "nucleus_admin_all",
  "cts_smoke_group-1",
  "cts_smoke_group-2",
  "cts_smoke_group-3",
  "cts_smoke_group-4",
  "cts_smoke_group-5",
  "servlet_tck_servlet-api-servlet",
  "servlet_tck_servlet-api-servlet-http",
  "servlet_tck_servlet-compat",
  "servlet_tck_servlet-pluggability",
  "servlet_tck_servlet-spec",
  "findbugs_all",
  "findbugs_low_priority_all",
  "jdbc_all",
  "jms_all",
  "copyright",
  "batch_all",
  "naming_all",
  "persistence_all",
  "webservice_all",
  "connector_group_1",
  "connector_group_2",
  "connector_group_3",
  "connector_group_4"
]

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
                      //checkout scm
                      //unstash 'build-bundles'
                      unstash 'maven-repo'
                      sh 'ls -l /root/.m2/repository/org/glassfish/main/test'
                      //sh "${WORKSPACE}/appserver/tests/gftest.sh run_test ${job}"
                      //archiveArtifacts artifacts: "${job}-results.tar.gz"
                      //junit testResults: 'results/junitreports/*.xml', allowEmptyResults: true
                    }
                }
            }
        }
    }
}

pipeline {
  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }
  agent {
    kubernetes {
      label 'mypod'
      defaultContainer 'jnlp'
      yaml """
apiVersion: v1
kind: Pod
metadata:
spec:
  volumes:
    - name: maven-repo-shared-storage
      persistentVolumeClaim:
       claimName: maven-repo
    - name: maven-repo-local-storage
      emptyDir: {}
  hostAliases:
  - ip: "127.0.0.1"
    hostnames:
    - "localhost.localdomain"
  containers:
  - name: glassfish-ci
    image: arindamb/glassfish-ci
    command:
    - cat
    tty: true
    imagePullPolicy: Always
    volumeMounts:
        - mountPath: "/root/.m2/repository"
          name: maven-repo-shared-storage
        - mountPath: "/root/.m2/repository/org/glassfish/main"
          name: maven-repo-local-storage
    resources:
      limits:
        memory: "8Gi"
        cpu: "2"
"""
    }
  }
  environment {
    S1AS_HOME = "${WORKSPACE}/glassfish5/glassfish"
    APS_HOME = "${WORKSPACE}/appserver/tests/appserv-tests"
    TEST_RUN_LOG = "${WORKSPACE}/tests-run.log"
    ANT_OPTS = "-Xmx1024M \
                -Dhttp.proxyHost=www-proxy-hqdc.us.oracle.com \
                -Dhttp.proxyPort=80 \
                -Dhttps.proxyHost=www-proxy-hqdc.us.oracle.com \
                -Dhttps.proxyPort=80"
    MAVEN_OPTS = "${ANT_OPTS} -Dmaven.repo.local=/root/.m2/repository"
    CTS_SMOKE_URL = "http://sca00kou:8080/job/gf-cts-promotion/153/artifact/javaee-smoke-8.0_latest.zip"
    INTERNAL_RELEASE_REPO = "http://gf-maven.us.oracle.com/nexus/content/repositories/gf-internal-release"
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
          // sh '${WORKSPACE}/gfbuild.sh build_re_dev'
          sh '''
            mount
            df -h
            ls -ld /root/.m2/repository/org/glassfish/main/
            ls -l /root/.m2/repository/org/glassfish/main/
            mkdir /root/.m2/repository/org/glassfish/main/test
            touch /root/.m2/repository/org/glassfish/main/test/SUCCESS
          '''
          //archiveArtifacts artifacts: 'bundles/*.zip'
          //junit testResults: 'test-results/build-unit-tests/results/junitreports/test_results_junit.xml'
          //stash includes: 'bundles/*', name: 'build-bundles'
          stash includes: '/root/.m2/repository/org/glassfish/main/**/*', name: 'maven-repo'
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