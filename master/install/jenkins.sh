#! /bin/bash

#mkdir -p ${JENKINS_HOME}
echo "
>> create user and group
"
groupadd -g "${gid}" "${group}"
useradd -d "${JENKINS_HOME}" -u "${uid}" -g "${gid}" -m -s /bin/bash "${user}"
chown "${uid}":"${gid}" "${JENKINS_HOME}"
chown -R "${user}" "${JENKINS_HOME}" "${REF}"

echo "
>> download and check jenkins war file
"
JENKINS_WAR="/usr/share/jenkins/jenkins.war"
curl -fsSL "${JENKINS_URL}" -o "${JENKINS_WAR}"
echo "${JENKINS_SHA}  ${JENKINS_WAR}" | sha256sum -c -

echo "
>> download jenkins plugin manager
"
PLUGIN_INSTALLER="/usr/lib/jenkins-plugin-manager.jar"
curl -fsSL "${PLUGIN_CLI_URL}" -o "${PLUGIN_INSTALLER}"

echo "
>> download jenkins scripts
"
echo "
    >> install-plugins.sh
"
curl -fsSL https://raw.githubusercontent.com/jenkinsci/docker/master/install-plugins.sh -o /usr/local/bin/install-plugins.sh
chmod 755 /usr/local/bin/install-plugins.sh

echo "
    >> jenkins-support
"
curl -fsSL https://raw.githubusercontent.com/jenkinsci/docker/master/jenkins-support -o /usr/local/bin/jenkins-support
chmod 755 /usr/local/bin/jenkins-support

echo "
    >> jenkins.sh
"
curl -fsSL https://raw.githubusercontent.com/jenkinsci/docker/master/jenkins.sh -o /usr/local/bin/jenkins.sh
chmod 755 /usr/local/bin/jenkins.sh

echo "
    >> jenkins-plugin-cli.sh
"
curl -fsSL https://raw.githubusercontent.com/jenkinsci/docker/master/jenkins-plugin-cli.sh -o /bin/jenkins-plugin-cli
chmod 755 /bin/jenkins-plugin-cli

echo "
    >> jenkins-cx.sh
"
chmod 755 /usr/local/bin/jenkins-cx.sh

echo "
>> create folders
"
mkdir -p "${REF}/init.groovy.d"
mkdir -p "${LOCAL_PIPELINE_LIBRARY_PATH}"

echo "
>> install jenkins plugins
"
#/usr/local/bin/install-plugins.sh < "${REF}/plugins.txt"
java -jar "${PLUGIN_INSTALLER}" --war "${JENKINS_WAR}" --plugin-file "${REF}/plugins.txt" --verbose
