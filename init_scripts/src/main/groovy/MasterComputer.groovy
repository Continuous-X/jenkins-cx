

import com.continuousx.jenkins.image.hook.DefaultUser
import com.synopsys.arc.jenkins.plugins.ownership.OwnershipDescription
import com.synopsys.arc.jenkins.plugins.ownership.nodes.NodeOwnerHelper
import jenkins.model.Jenkins

HookScriptHelper.printHookStart(this)

println("== Configuring Master computer")

// Admin owns the node
NodeOwnerHelper.setOwnership(Jenkins.getInstanceOrNull(), new OwnershipDescription(true, DefaultUser.ADMIN_USERNAME))

HookScriptHelper.printHookEnd(this)