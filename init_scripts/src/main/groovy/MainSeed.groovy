import hudson.model.FreeStyleProject
import hudson.plugins.git.GitSCM
import javaposse.jobdsl.plugin.LookupStrategy
import javaposse.jobdsl.plugin.RemovedConfigFilesAction
import javaposse.jobdsl.plugin.RemovedJobAction
import javaposse.jobdsl.plugin.RemovedViewAction
import jenkins.model.Jenkins
import javaposse.jobdsl.plugin.ExecuteDslScripts

//HookScriptHelper.printHookStart(this)
println """
###################################
# boot - MainSeed Hook (start)    #
###################################
"""

Jenkins jenkins = Jenkins.getInstanceOrNull()
String jobName = 'MainSeed'
String dslScript = 'MainSeed.groovy'
boolean createMainSeed = Boolean.getBoolean("io.jenkins.dev.mainseed.create")
String jenkinsconfigRepository = java.lang.System.getenv("jenkins.config.repository")
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

FreeStyleProject mainseedJob = new FreeStyleProject(jenkins, jobName)
mainseedJob.setDisplayName(jobName)
mainseedJob.setScm(new GitSCM(jenkinsconfigRepository))
mainseedJob.getBuildersList().add(executeDslScripts)
/*mainseedJob.setAssignedNode('master')
mainseedJob.setAssignedLabel(jenkins.getla)*/
mainseedJob.save()

jenkins.reload()

//HookScriptHelper.printHookEnd(this)
println """
#################################
# boot - MainSeed Hook (end)    #
#################################
"""
