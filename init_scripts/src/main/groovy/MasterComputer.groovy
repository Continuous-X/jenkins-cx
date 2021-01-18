import com.synopsys.arc.jenkins.plugins.ownership.OwnershipDescription
import com.synopsys.arc.jenkins.plugins.ownership.nodes.NodeOwnerHelper
import jenkins.model.Jenkins

println """
###############################
# boot - ${this.getClass().getName()} (start)  #
###############################
"""

final String ADMIN_USERNAME = 'admin'

println("== Configuring Master computer")

// Admin owns the node
NodeOwnerHelper.setOwnership(Jenkins.getInstanceOrNull(), new OwnershipDescription(true, ADMIN_USERNAME))

println """
###############################
# boot - ${this.getClass().getName()} (end)  #
###############################
"""