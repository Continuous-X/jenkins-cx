package scripts

import com.cx.jenkins.image.hook.HookScriptHelper

HookScriptHelper.printHookStart(this)

println("== Configuring Master computer")

// Admin owns the node
//NodeOwnerHelper.setOwnership(Jenkins.getInstanceOrNull(), new OwnershipDescription(true, "admin"))

HookScriptHelper.printHookEnd(this)