package scripts

import com.cx.jenkins.image.hook.HookScriptHelper
import jenkins.model.Jenkins
import jenkins.model.JenkinsLocationConfiguration

HookScriptHelper.printHookStart(this)

def jenkins = Jenkins.getInstanceOrNull()
assert jenkins != null: "Jenkins instance is null"

if (!jenkins.isQuietingDown()) {
    println("=== Setting Jenkins URL")
    def influxdb = Jenkins.instance.getDescriptorByType(jenkinsci.plugins.influxdb.InfluxDbStep.DescriptorImpl)

// Create target
    def target = new jenkinsci.plugins.influxdb.models.Target()

// Set target details

// Mandatory fields
    target.description = 'my-new-target'
    target.url = 'http://influxdburl:8086'
    target.username = 'my-username'

// version < 2.0
    target.password = 'my-password'

// version >= 2.0
    target.password = hudson.util.Secret.fromString('my-password')

    target.database = 'my-database'

// Optional fields
    target.retentionPolicy = '1d'                    // default = 'autogen'
    target.jobScheduledTimeAsPointsTimestamp = true  // default = false
    target.exposeExceptions = true                   // default = true
    target.usingJenkinsProxy = true                  // default = false

// Add a target by using the created target object
    influxdb.addTarget(target)
    influxdb.save()

// Write stuff to InfluxDB
    influxDbPublisher(selectedTarget: 'my-new-target')

// Remove a target by using the target description field value
    influxdb.removeTarget('my-new-target')
    influxdb.save()
} else {
    println '*** Shutdown mode enabled. Configure Jenkins is SKIPPED!'
}

HookScriptHelper.printHookEnd(this)