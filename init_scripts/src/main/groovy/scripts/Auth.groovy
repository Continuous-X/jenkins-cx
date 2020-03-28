package scripts

import com.cx.jenkins.image.hook.HookScriptHelper
import hudson.model.User
import hudson.security.SecurityRealm
import jenkins.model.Jenkins
import jenkins.security.QueueItemAuthenticatorConfiguration
import org.jenkinsci.plugins.authorizeproject.GlobalQueueItemAuthenticator
import org.jenkinsci.plugins.authorizeproject.strategy.TriggeringUsersAuthorizationStrategy

HookScriptHelper.printHookStart(this)

boolean createAdmin = Boolean.getBoolean("io.jenkins.dev.security.createAdmin")

println("=== Configuring users")
SecurityRealm securityRealm = Jenkins.getInstanceOrNull().getSecurityRealm()
User user = securityRealm.createAccount("user", "user")
user.setFullName("User")
if (createAdmin) {
    User admin = securityRealm.createAccount("admin", "admin")
    admin.setFullName("Admin")
}

println("=== Configure Authorize Project")
GlobalQueueItemAuthenticator auth = new GlobalQueueItemAuthenticator(
    new TriggeringUsersAuthorizationStrategy()
)
QueueItemAuthenticatorConfiguration.get().authenticators.add(auth)

HookScriptHelper.printHookEnd(this)