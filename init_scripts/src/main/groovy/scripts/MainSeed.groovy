package scripts

import com.cx.jenkins.image.hook.HookScriptHelper
import hudson.model.FreeStyleProject
import hudson.plugins.git.BranchSpec
import hudson.plugins.git.GitSCM
import javaposse.jobdsl.plugin.LookupStrategy
import javaposse.jobdsl.plugin.RemovedConfigFilesAction
import javaposse.jobdsl.plugin.RemovedJobAction
import javaposse.jobdsl.plugin.RemovedViewAction
import jenkins.model.Jenkins
import javaposse.jobdsl.plugin.ExecuteDslScripts

HookScriptHelper.printHookStart(this)

Jenkins jenkins = Jenkins.getInstanceOrNull()
String jobName = 'MainSeed'
String dslScript = 'src/main/groovy/MainSeed.groovy'
boolean createMainSeed = Boolean.getBoolean("io.jenkins.dev.mainseed.create")
if (createMainSeed) {
    println "create the masterseed job"
    String jenkinsconfigRepository = java.lang.System.getProperty("io.jenkins.dev.mainseed.repository")
    println "createMainSeed: ${createMainSeed}"
    println "jenkinsConfigRepo: ${jenkinsconfigRepository}"

    ExecuteDslScripts executeDslScripts = new ExecuteDslScripts()
    executeDslScripts.setTargets(dslScript)
    executeDslScripts.setSandbox(false)
    executeDslScripts.setUseScriptText(false)
    executeDslScripts.setIgnoreExisting(false)
    executeDslScripts.setIgnoreMissingFiles(false)
    executeDslScripts.setFailOnMissingPlugin(true)
    executeDslScripts.setFailOnSeedCollision(true)
    executeDslScripts.setUnstableOnDeprecation(false)
    executeDslScripts.setRemovedJobAction(RemovedJobAction.DELETE)
    executeDslScripts.setRemovedViewAction(RemovedViewAction.DELETE)
    executeDslScripts.setRemovedConfigFilesAction(RemovedConfigFilesAction.DELETE)
    executeDslScripts.setLookupStrategy(LookupStrategy.JENKINS_ROOT)

    GitSCM scm = new GitSCM(jenkinsconfigRepository)
    scm.branches = Collections.singletonList(new BranchSpec("master"))

    FreeStyleProject mainseedJob = new FreeStyleProject(jenkins, jobName)
    mainseedJob.setDisplayName(jobName)
    mainseedJob.setScm(scm)
    mainseedJob.getBuildersList().add(executeDslScripts)
    /*mainseedJob.setAssignedNode()
    mainseedJob.setAssignedLabel(jenkins.getla)*/
    mainseedJob.save()

    jenkins.reload()
} else {
    println "don't create the masterseed job"
}

HookScriptHelper.printHookEnd(this)
