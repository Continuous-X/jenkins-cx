FROM jenkins/jenkins:2.243-alpine

ARG DEV_HOST=localhost
ARG CREATE_ADMIN=true
ARG GITHUB_API_TOKEN='default'
ARG CREATE_MAINSEED=true
ARG ALLOW_RUNS_ON_MASTER=false
ARG LOCAL_PIPELINE_LIBRARY_PATH="${JENKINS_HOME}/pipeline-library"
ARG VERSION="0.1"
ARG JENKINS_CONFIG_REPO="https://github.com/Continuous-X/jenkins-cx-config-demo-project.git"
ARG JENKINS_CONFIG_CASC="master/jenkins.yaml"
ARG RUNTIME_USER="jenkins"
ARG RUNTIME_GROUP="jenkins"
ARG INFLUXDB_HOSTNAME="localhost"
ARG INFLUXDB_PORT="8086"

ENV JENKINS_CONFIG_CREATE_ADMIN="${CREATE_ADMIN}" \
    JENKINS_CONFIG_GITHUB_API_USER_TOKEN="${GITHUB_API_TOKEN}" \
    JENKINS_CONFIG_INFLUXDB_HOSTNAME="${INFLUXDB_HOSTNAME}" \
    JENKINS_CONFIG_INFLUXDB_PORT="${INFLUXDB_PORT}" \
    JENKINS_CONFIG_ALLOW_RUNS_ON_MASTER="${ALLOW_RUNS_ON_MASTER}" \
    JENKINS_CONFIG_MAINSEED_CREATE="${CREATE_MAINSEED}" \
    JENKINS_CONFIG_REPO="${JENKINS_CONFIG_REPO}" \
    JENKINS_CONFIG_CASC="${JENKINS_CONFIG_CASC}" \
    CASC_JENKINS_CONFIG="${JENKINS_HOME}/casc_configs/jenkins.yaml" \
    LOCAL_PIPELINE_LIBRARY_PATH="${LOCAL_PIPELINE_LIBRARY_PATH}" \
    RUNTIME_USER="${RUNTIME_USER}" \
    RUNTIME_GROUP="${RUNTIME_GROUP}"

LABEL maintainer="wolver.minion" \
      Description="Setup Jenkins Config-as-Code with Docker, Pipeline, and Groovy Hook Scripts. thx Oleg" \
      Vendor="Wolver" \
      Version="${VERSION}"

USER root

COPY master/plugins.txt ${REF}/plugins.txt
COPY init_scripts/src/main/groovy/ ${REF}/init.groovy.d/
COPY master/jenkins-cx.sh /usr/local/bin/jenkins-cx.sh
COPY ${JENKINS_CONFIG_CASC} ${CASC_JENKINS_CONFIG}

RUN apk add --no-cache --update openssl && \
    rm -rf /var/cache/apk/*
RUN /usr/local/bin/install-plugins.sh < ${REF}/plugins.txt; \
    mkdir -p ${LOCAL_PIPELINE_LIBRARY_PATH}

USER ${RUNTIME_USER}

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins-cx.sh"]
