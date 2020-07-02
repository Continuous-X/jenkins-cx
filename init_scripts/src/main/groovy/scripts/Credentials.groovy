package scripts

import com.continuousx.jenkins.image.hook.DefaultUser
import com.continuousx.jenkins.image.hook.HookScriptHelper
import hudson.model.User
import hudson.security.HudsonPrivateSecurityRealm
import jenkins.model.Jenkins
import jenkins.security.QueueItemAuthenticatorConfiguration
import org.jenkinsci.plugins.authorizeproject.GlobalQueueItemAuthenticator
import org.jenkinsci.plugins.authorizeproject.strategy.TriggeringUsersAuthorizationStrategy

HookScriptHelper.printHookStart(this)

String githubApiToken = java.lang.System.getProperty("io.jenkins.dev.github.api.token")

println("=== Configuring credentials")
if (githubApiToken.length() > 0) {
    HudsonPrivateSecurityRealm securityRealm = Jenkins.getInstanceOrNull().getSecurityRealm()
    User ghApiUser = securityRealm.createcAccount(DefaultUser.GITHUB_API_USER_USERNAME, DefaultUser.ADMIN_PASSWORD)
    ghApiUser.setFullName(DefaultUser.GITHUB_API_USER_FULLNAME)
}

println("=== Configure Authorize Project")
GlobalQueueItemAuthenticator auth = new GlobalQueueItemAuthenticator(
    new TriggeringUsersAuthorizationStrategy()
)
QueueItemAuthenticatorConfiguration.get().authenticators.add(auth)

HookScriptHelper.printHookEnd(this)