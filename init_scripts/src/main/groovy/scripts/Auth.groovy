package scripts

import com.cx.jenkins.image.hook.DefaultUser
import com.cx.jenkins.image.hook.HookScriptHelper
import hudson.model.User
import hudson.security.HudsonPrivateSecurityRealm
import jenkins.model.Jenkins
import jenkins.security.QueueItemAuthenticatorConfiguration
import org.jenkinsci.plugins.authorizeproject.GlobalQueueItemAuthenticator
import org.jenkinsci.plugins.authorizeproject.strategy.TriggeringUsersAuthorizationStrategy

HookScriptHelper.printHookStart(this)

boolean createAdmin = Boolean.getBoolean("io.jenkins.dev.security.createAdmin")

println("=== Configuring users")
HudsonPrivateSecurityRealm securityRealm = Jenkins.getInstanceOrNull().getSecurityRealm()
User user = securityRealm.createAccount(DefaultUser.USER_USERNAME, DefaultUser.USER_PASSWORD)
user.setFullName(DefaultUser.USER_FULLNAME)
if (createAdmin) {
    User admin = securityRealm.createAccount(DefaultUser.ADMIN_USERNAME, DefaultUser.ADMIN_PASSWORD)
    admin.setFullName(DefaultUser.ADMIN_FULLNAME)
}

println("=== Configure Authorize Project")
GlobalQueueItemAuthenticator auth = new GlobalQueueItemAuthenticator(
    new TriggeringUsersAuthorizationStrategy()
)
QueueItemAuthenticatorConfiguration.get().authenticators.add(auth)

HookScriptHelper.printHookEnd(this)