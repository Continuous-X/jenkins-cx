FROM adoptopenjdk/openjdk11:armv7l-ubuntu-jdk-11.0.8_10-slim
#FROM jenkins4eval/jenkins:2.273-slim-arm

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG http_port=8080
ARG agent_port=50000
ARG JENKINS_HOME=/var/jenkins_home
ARG REF=/usr/share/jenkins/ref

ENV JENKINS_HOME $JENKINS_HOME
ENV JENKINS_SLAVE_AGENT_PORT ${agent_port}
ENV REF $REF

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

ENV CREATE_ADMIN="${CREATE_ADMIN}" \
    GITHUB_API_TOKEN="${GITHUB_API_TOKEN}" \
    INFLUXDB_HOSTNAME="${INFLUXDB_HOSTNAME}" \
    INFLUXDB_PORT="${INFLUXDB_PORT}" \
    ALLOW_RUNS_ON_MASTER="${ALLOW_RUNS_ON_MASTER}" \
    CREATE_MAINSEED="${CREATE_MAINSEED}" \
    JENKINS_CONFIG_REPO="${JENKINS_CONFIG_REPO}" \
    JENKINS_CONFIG_CASC="${JENKINS_CONFIG_CASC}" \
    CASC_JENKINS_CONFIG="${JENKINS_HOME}/casc_configs/jenkins.yaml" \
    LOCAL_PIPELINE_LIBRARY_PATH="${LOCAL_PIPELINE_LIBRARY_PATH}" \
    RUNTIME_USER="${user}" \
    RUNTIME_GROUP="${group}"

LABEL maintainer="wolver.minion" \
      Description="Setup Jenkins Config-as-Code with Docker, Pipeline, and Groovy Hook Scripts. thx Oleg" \
      Vendor="Wolver" \
      Version="${VERSION}"

USER root

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y git unzip git-lfs gpg tini
RUN apt-get autoclean -y
RUN apt-get autoremove -y

# Jenkins is run with user `jenkins`, uid = 1000
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
RUN mkdir -p ${JENKINS_HOME} \
  && chown ${uid}:${gid} ${JENKINS_HOME} \
  && groupadd -g ${gid} ${group} \
  && useradd -d "${JENKINS_HOME}" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME $JENKINS_HOME

# $REF (defaults to `/usr/share/jenkins/ref/`) contains all reference configuration we want
# to set on a fresh new installation. Use it to bundle additional plugins
# or config file with your custom jenkins Docker image.
RUN mkdir -p ${REF}/init.groovy.d

# jenkins version being bundled in this docker image
ARG JENKINS_VERSION
ENV JENKINS_VERSION ${JENKINS_VERSION:-2.274}

# jenkins.war checksum, download will be validated using it
ARG JENKINS_SHA=5ed7c22531343af7ae6e72ef78badfd2d5098a6ca658c990ed1795a7e54c57a9

# Can be used to customize where jenkins.war get downloaded from
ARG JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war

# could use ADD but this one does not check Last-Modified header neither does it allow to control checksum
# see https://github.com/docker/docker/issues/8331
RUN curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war \
  && echo "${JENKINS_SHA}  /usr/share/jenkins/jenkins.war" | sha256sum -c -

ENV JENKINS_UC https://updates.jenkins.io
ENV JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental
ENV JENKINS_INCREMENTALS_REPO_MIRROR=https://repo.jenkins-ci.org/incrementals
RUN chown -R ${user} "$JENKINS_HOME" "$REF"

# jenkins version being bundled in this docker image
ARG PLUGIN_INSTALLATION_MANAGER_TOOL_VERSION
ENV PLUGIN_INSTALLATION_MANAGER_TOOL_VERSION ${PLUGIN_INSTALLATION_MANAGER_TOOL_VERSION:-2.5.0}

ARG PLUGIN_CLI_URL=https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/${PLUGIN_INSTALLATION_MANAGER_TOOL_VERSION}/jenkins-plugin-manager-${PLUGIN_INSTALLATION_MANAGER_TOOL_VERSION}.jar
RUN curl -fsSL ${PLUGIN_CLI_URL} -o /usr/lib/jenkins-plugin-manager.jar

# for main web interface:
EXPOSE ${http_port}

# will be used by attached slave agents:
EXPOSE ${agent_port}

ENV COPY_REFERENCE_FILE_LOG ${JENKINS_HOME}/copy_reference_file.log

# from a derived Dockerfile, can use `RUN install-plugins.sh active.txt` to setup $REF/plugins from a support bundle
RUN curl -fsSL https://raw.githubusercontent.com/jenkinsci/docker/master/install-plugins.sh -o /usr/local/bin/install-plugins.sh
RUN curl -fsSL https://raw.githubusercontent.com/jenkinsci/docker/master/jenkins-support -o /usr/local/bin/jenkins-support
RUN curl -fsSL https://raw.githubusercontent.com/jenkinsci/docker/master/jenkins.sh -o /usr/local/bin/jenkins.sh
RUN curl -fsSL https://raw.githubusercontent.com/jenkinsci/docker/master/tini-shim.sh -o /bin/tini
RUN curl -fsSL https://raw.githubusercontent.com/jenkinsci/docker/master/jenkins-plugin-cli.sh -o /bin/jenkins-plugin-cli

COPY master/plugins.txt ${REF}/plugins.txt
COPY init_scripts/src/main/groovy/ ${REF}/init.groovy.d/
COPY master/jenkins-cx.sh /usr/local/bin/jenkins-cx.sh
ADD ${JENKINS_CONFIG_CASC} ${CASC_JENKINS_CONFIG}

RUN /usr/local/bin/install-plugins.sh < ${REF}/plugins.txt; \
    mkdir -p ${LOCAL_PIPELINE_LIBRARY_PATH}

#USER ${RUNTIME_USER}

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins-cx.sh"]
