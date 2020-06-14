package scripts

import com.cx.jenkins.image.hook.HookScriptHelper
import hudson.util.Secret
import jenkins.model.Jenkins
import jenkinsci.plugins.influxdb.InfluxDbGlobalConfig
import jenkinsci.plugins.influxdb.models.Target

HookScriptHelper.printHookStart(this)

final String INFLUXDB_TARGET_CX_OPERATING = 'cx-operating'
final String INFLUXDB_TARGET_CX_CICD = 'cx-cicd'

def influxdbTargets = [
        operating: [
                description: INFLUXDB_TARGET_CX_OPERATING,
                url: 'http://localhost:8086',
                username: '',
                password: '',
                database: 'cx_sharedlib_metrics',
                retentionPolicy: 'autogen',
                jobScheduledTimeAsPointsTimestamp: 'true',
                exposeExceptions: 'true',
                usingJenkinsProxy: 'true',
                globalListener: false,
                globalListenerFilter: ''
        ],
        cicd: [
                description: INFLUXDB_TARGET_CX_CICD,
                url: 'http://localhost:8086',
                username: '',
                password: '',
                database: 'cx_sharedlib_metrics',
                retentionPolicy: 'autogen',
                jobScheduledTimeAsPointsTimestamp: 'true',
                exposeExceptions: 'true',
                usingJenkinsProxy: 'true',
                globalListener: false,
                globalListenerFilter: ''
        ]
]

def jenkins = Jenkins.getInstanceOrNull()
assert jenkins != null: "Jenkins instance is null"

if (!jenkins.isQuietingDown()) {
    InfluxDbGlobalConfig influxdb = InfluxDbGlobalConfig.getInstance()

    //metric target operating
    println("=== Setting InfluxDB Target ${influxdbTargets.operating.description}")
    influxdb.removeTarget(influxdbTargets.operating.description)
    Target target = new Target()
    target.description = influxdbTargets.operating.description
    target.url = influxdbTargets.operating.url
    target.username = influxdbTargets.operating.username
    target.password = Secret.fromString(influxdbTargets.operating.password)
    target.database = influxdbTargets.operating.database
    target.retentionPolicy = influxdbTargets.operating.retentionPolicy
    target.jobScheduledTimeAsPointsTimestamp = influxdbTargets.operating.jobScheduledTimeAsPointsTimestamp
    target.exposeExceptions = influxdbTargets.operating.exposeExceptions
    target.usingJenkinsProxy = influxdbTargets.operating.usingJenkinsProxy
    target.globalListener = influxdbTargets.operating.globalListener
    target.globalListenerFilter = influxdbTargets.operating.globalListenerFilter
    influxdb.addTarget(target)

    //metric target cicd
    println("=== Setting InfluxDB Target ${influxdbTargets.cicd.description}")
    influxdb.removeTarget(influxdbTargets.cicd.description)
    Target target2 = new Target()
    target2.description = influxdbTargets.cicd.description
    target2.url = influxdbTargets.cicd.url
    target2.username = influxdbTargets.cicd.username
    target2.password = Secret.fromString(influxdbTargets.cicd.password)
    target2.database = influxdbTargets.cicd.database
    target2.retentionPolicy = influxdbTargets.cicd.retentionPolicy
    target2.jobScheduledTimeAsPointsTimestamp = influxdbTargets.cicd.jobScheduledTimeAsPointsTimestamp
    target2.exposeExceptions = influxdbTargets.cicd.exposeExceptions
    target2.usingJenkinsProxy = influxdbTargets.cicd.usingJenkinsProxy
    target2.globalListener = influxdbTargets.cicd.globalListener
    target2.globalListenerFilter = influxdbTargets.cicd.globalListenerFilter
    influxdb.addTarget(target2)

    influxdb.save()
} else {
    println '*** Shutdown mode enabled. Configure Jenkins is SKIPPED!'
}

HookScriptHelper.printHookEnd(this)