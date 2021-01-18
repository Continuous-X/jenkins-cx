class HookScriptHelper {

    public static void printHookStart(Object hook) {
        java.lang.System.println """
###############################
# boot - ${hook.getClass().getName()} (start)  #
###############################
"""
    }

    public static void printHookEnd(Object hook) {
        java.lang.System.println """
###############################
# boot - ${hook.getClass().getName()} (end)  #
###############################
"""
    }
}
