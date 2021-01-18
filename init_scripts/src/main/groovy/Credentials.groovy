import com.cloudbees.plugins.credentials.CredentialsScope
import com.cloudbees.plugins.credentials.SystemCredentialsProvider
import com.cloudbees.plugins.credentials.domains.Domain
import com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl
import hudson.ExtensionList
import jenkins.model.Jenkins

import static com.continuousx.jenkins.image.hook.Credentials.*

HookScriptHelper.printHookStart(this)

String githubApiToken = java.lang.System.getProperty("io.jenkins.dev.github.api.token")

println("=== Configuring credentials")
if (githubApiToken.length() > 0) {
    Domain globalDomain = Domain.global()
    ExtensionList extensionList = Jenkins.getInstanceOrNull().getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')
    extensionList.each { extension ->
        SystemCredentialsProvider provider = extension as SystemCredentialsProvider
        SystemCredentialsProvider.StoreImpl store = provider.getStore()
        UsernamePasswordCredentialsImpl githubAccount = new UsernamePasswordCredentialsImpl(
                CredentialsScope.GLOBAL,
                GITHUB_API_CREDENTIAL_ID,
                GITHUB_API_CREDENTIAL_DESCRIPTION,
                GITHUB_API_CREDENTIAL_USER_NAME,
                githubApiToken
        )
        store.addCredentials(globalDomain, githubAccount)

    }
}

HookScriptHelper.printHookEnd(this)
