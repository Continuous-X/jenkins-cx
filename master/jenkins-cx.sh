#! /bin/bash -e
# Additional wrapper, which adds custom environment options for the run
set

extra_java_opts=( \
  '-Djenkins.install.runSetupWizard=false -Djenkins.model.Jenkins.slaveAgentPort=50000' \
  '-Djenkins.model.Jenkins.slaveAgentPortEnforce=true' \
  "-Dio.jenkins.dev.security.createAdmin=${CREATE_ADMIN}" \
  "-Dio.jenkins.dev.github.api.token=${GITHUB_API_TOKEN}" \
  "-Dio.jenkins.dev.security.allowRunsOnMaster=${ALLOW_RUNS_ON_MASTER}" \
  '-Dhudson.model.LoadStatistics.clock=1000' \
  "-Dio.jenkins.dev.influxdb.hostname=${INFLUXDB_HOSTNAME}" \
  "-Dio.jenkins.dev.influxdb.port=${INFLUXDB_PORT}" \
  "-Dio.jenkins.dev.mainseed.repository=${JENKINS_CONFIG_REPO}" \
  "-Dio.jenkins.dev.mainseed.create=${CREATE_MAINSEED}"
)

if [ -z "$DEV_HOST" ] ; then
  echo "WARNING: DEV_HOST is undefined, localhost will be used. Some logic like Docker Cloud may work incorrectly."
else
  extra_java_opts+=( "-Dio.jenkins.dev.host=${DEV_HOST}" )
fi

if [[ "$DEBUG" ]] ; then
  extra_java_opts+=( \
    '-Xdebug' \
    '-Xrunjdwp:server=y,transport=dt_socket,address=5005,suspend=y' \
  )
fi

copyPlugins() {

  cp -R ${REF}/plugins/* ${JENKINS_HOME}/plugins
}

#copyPlugins

export JAVA_OPTS="$JAVA_OPTS ${extra_java_opts[@]}"
echo "${JAVA_OPTS}"
exec /usr/local/bin/jenkins.sh "$@"