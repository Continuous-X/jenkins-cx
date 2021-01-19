FROM adoptopenjdk/openjdk11:x86_64-ubuntu-jdk-11.0.9.1_1-slim

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG http_port=8080
ARG agent_port=50000
ARG JENKINS_HOME=/var/jenkins_home
ARG REF=/usr/share/jenkins/ref
ARG DEV_HOST=localhost
ARG CREATE_ADMIN=true
ARG GITHUB_API_TOKEN='default'
ARG CREATE_MAINSEED=true
ARG ALLOW_RUNS_ON_MASTER=false
ARG LOCAL_PIPELINE_LIBRARY_PATH="${JENKINS_HOME}/pipeline-library"
ARG VERSION="0.1"
ARG JENKINS_CONFIG_REPO="https://github.com/Continuous-X/jenkins-cx-config-demo-project.git"
ARG JENKINS_CONFIG_CASC="master/jenkins.yaml"
ARG INFLUXDB_HOSTNAME="localhost"
ARG INFLUXDB_PORT="8086"
ARG TINI_VERSION="v0.19.0"
ARG JENKINS_VERSION="2.275"
ARG JENKINS_SHA=2db5deb9f119bc955ba0922b7cb239d9e18ab1000ec44493959b600f6ecda2d3
ARG PLUGIN_INSTALLATION_MANAGER_TOOL_VERSION="2.5.0"

ENV JENKINS_VERSION="${JENKINS_VERSION}" \
    JENKINS_HOME="${JENKINS_HOME}" \
    JENKINS_SLAVE_AGENT_PORT="${agent_port}" \
    #JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war \
    JENKINS_URL=https://updates.jenkins-ci.org/download/war/${JENKINS_VERSION}/jenkins.war \
    JENKINS_UC="https://updates.jenkins.io" \
    JENKINS_UC_EXPERIMENTAL="https://updates.jenkins.io/experimental" \
    JENKINS_INCREMENTALS_REPO_MIRROR="https://repo.jenkins-ci.org/incrementals" \
    JENKINS_CONFIG_REPO="${JENKINS_CONFIG_REPO}" \
    JENKINS_CONFIG_CASC="${JENKINS_CONFIG_CASC}" \
    REF="${REF}" \
    CREATE_ADMIN="${CREATE_ADMIN}" \
    ALLOW_RUNS_ON_MASTER="${ALLOW_RUNS_ON_MASTER}" \
    CASC_JENKINS_CONFIG="${JENKINS_HOME}/casc_configs/jenkins.yaml" \
    LOCAL_PIPELINE_LIBRARY_PATH="${LOCAL_PIPELINE_LIBRARY_PATH}" \
    CREATE_MAINSEED="${CREATE_MAINSEED}" \
    PLUGIN_INSTALLATION_MANAGER_TOOL_VERSION="${PLUGIN_INSTALLATION_MANAGER_TOOL_VERSION}" \
    PLUGIN_CLI_URL="https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/${PLUGIN_INSTALLATION_MANAGER_TOOL_VERSION}/jenkins-plugin-manager-${PLUGIN_INSTALLATION_MANAGER_TOOL_VERSION}.jar" \
    GITHUB_API_TOKEN="${GITHUB_API_TOKEN}" \
    INFLUXDB_HOSTNAME="${INFLUXDB_HOSTNAME}" \
    INFLUXDB_PORT="${INFLUXDB_PORT}" \
    RUNTIME_USER="${user}" \
    RUNTIME_GROUP="${group}" \
    COPY_REFERENCE_FILE_LOG="${JENKINS_HOME}/copy_reference_file.log"

LABEL maintainer="wolver.minion" \
      Description="Setup Jenkins Config-as-Code with Docker, Pipeline, and Groovy Hook Scripts. thx Oleg" \
      Vendor="Wolver" \
      Version="${VERSION}"

USER root

RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y git unzip git-lfs gpg \
    && apt-get autoclean -y \
    && apt-get autoremove -y \
    && mkdir -p ${JENKINS_HOME} \
    && chown ${uid}:${gid} ${JENKINS_HOME} \
    && groupadd -g ${gid} ${group} \
    && useradd -d "${JENKINS_HOME}" -u ${uid} -g ${gid} -m -s /bin/bash ${user} \
    && mkdir -p ${REF}/init.groovy.d \
    && curl -fsSL https://raw.githubusercontent.com/jenkinsci/docker/master/tini_pub.gpg -o ${JENKINS_HOME}/tini_pub.gpg \
    && curl -fsSL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-armhf -o /sbin/tini \
    && curl -fsSL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-armhf.asc -o /sbin/tini.asc \
    && gpg --no-tty --import ${JENKINS_HOME}/tini_pub.gpg \
    && gpg --verify /sbin/tini.asc \
    && rm -rf /sbin/tini.asc /root/.gnupg \
    && chmod 755 /sbin/tini \
    && curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war \
    && echo "${JENKINS_SHA}  /usr/share/jenkins/jenkins.war" | sha256sum -c - \
    && chown -R ${user} "$JENKINS_HOME" "$REF" \
    && curl -fsSL ${PLUGIN_CLI_URL} -o /usr/lib/jenkins-plugin-manager.jar \
    && curl -fsSL https://raw.githubusercontent.com/jenkinsci/docker/master/install-plugins.sh -o /usr/local/bin/install-plugins.sh \
    && curl -fsSL https://raw.githubusercontent.com/jenkinsci/docker/master/jenkins-support -o /usr/local/bin/jenkins-support \
    && curl -fsSL https://raw.githubusercontent.com/jenkinsci/docker/master/jenkins.sh -o /usr/local/bin/jenkins.sh \
    && curl -fsSL https://raw.githubusercontent.com/jenkinsci/docker/master/tini-shim.sh -o /bin/tini \
    && curl -fsSL https://raw.githubusercontent.com/jenkinsci/docker/master/jenkins-plugin-cli.sh -o /bin/jenkins-plugin-cli \
    && chmod 755 /usr/local/bin/install-plugins.sh \
    && chmod 755 /usr/local/bin/jenkins-support \
    && chmod 755 /usr/local/bin/jenkins.sh \
    && chmod 755 /sbin/tini \
    && chmod 755 /bin/tini \
    && chmod 755 /bin/jenkins-plugin-cli

COPY master/plugins.txt ${REF}/plugins.txt
COPY master/logging.properties ${REF}/logging.properties
COPY init_scripts/src/main/groovy/ ${REF}/init.groovy.d/
COPY master/jenkins-cx.sh /usr/local/bin/jenkins-cx.sh
ADD ${JENKINS_CONFIG_CASC} ${CASC_JENKINS_CONFIG}

#RUN /bin/jenkins-plugin-cli -f ${REF}/plugins.txt \
RUN chmod 755 /usr/local/bin/jenkins-cx.sh \
    && /usr/local/bin/install-plugins.sh < ${REF}/plugins.txt \
    && mkdir -p ${LOCAL_PIPELINE_LIBRARY_PATH}

VOLUME ${JENKINS_HOME}

# for main web interface:
EXPOSE ${http_port}
# will be used by attached slave agents:
EXPOSE ${agent_port}

USER ${RUNTIME_USER}

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins-cx.sh"]
