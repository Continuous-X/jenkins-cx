#! /bin/bash

echo "
>> download tini files for install
"
curl -fsSL "https://raw.githubusercontent.com/jenkinsci/docker/master/tini_pub.gpg" -o "${JENKINS_HOME}/tini_pub.gpg"
curl -fsSL "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/${TINI_BIN}" -o /sbin/tini
curl -fsSL "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/${TINI_BIN}.asc" -o /sbin/tini.asc
echo "${TINI_SHA}  /sbin/tini" | sha256sum -c -

echo "
>> install tini
"
gpg --no-tty --import "${JENKINS_HOME}/tini_pub.gpg"
gpg --verify /sbin/tini.asc
rm -rf /sbin/tini.asc /root/.gnupg
chmod 755 /sbin/tini
/sbin/tini --version

echo "
>> download tini from jenkinsci
"
curl -fsSL "https://raw.githubusercontent.com/jenkinsci/docker/master/tini-shim.sh" -o /bin/tini
chmod 755 /bin/tini
