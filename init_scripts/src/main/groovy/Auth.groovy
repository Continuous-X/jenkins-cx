import hudson.model.User
import hudson.security.HudsonPrivateSecurityRealm
import jenkins.model.Jenkins
import jenkins.security.QueueItemAuthenticatorConfiguration
import org.jenkinsci.plugins.authorizeproject.GlobalQueueItemAuthenticator
import org.jenkinsci.plugins.authorizeproject.strategy.TriggeringUsersAuthorizationStrategy

println """
###############################
# boot - ${this.getClass().getName()} (start)  #
###############################
"""

final String ADMIN_FULLNAME = 'Admin'
final String ADMIN_USERNAME = 'admin'
final String ADMIN_PASSWORD = 'admin'
final String USER_FULLNAME = 'User'
final String USER_USERNAME = 'user'
final String USER_PASSWORD = 'user'

boolean createAdmin = Boolean.getBoolean("io.jenkins.dev.security.createAdmin")

println("=== Configuring users")
HudsonPrivateSecurityRealm securityRealm = Jenkins.getInstanceOrNull().getSecurityRealm()
User user = securityRealm.createAccount(USER_USERNAME, USER_PASSWORD)
user.setFullName(USER_FULLNAME)
if (createAdmin) {
    User admin = securityRealm.createAccount(ADMIN_USERNAME, ADMIN_PASSWORD)
    admin.setFullName(ADMIN_FULLNAME)
}

println("=== Configure Authorize Project")
GlobalQueueItemAuthenticator auth = new GlobalQueueItemAuthenticator(
    new TriggeringUsersAuthorizationStrategy()
)
QueueItemAuthenticatorConfiguration.get().authenticators.add(auth)

println """
###############################
# boot - ${this.getClass().getName()} (end)  #
###############################
"""