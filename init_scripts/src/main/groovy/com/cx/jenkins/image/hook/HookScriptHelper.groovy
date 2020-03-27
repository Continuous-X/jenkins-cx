package com.cx.jenkins.image.hook

class HookScriptHelper {

    public static void printHookStart(Object hook) {
        System.println """
###############################
# boot - ${hook.getClass().getName()} (start)  #
###############################
"""
    }

    public static void printHookEnd(Object hook) {
        System.println """
###############################
# boot - ${hook.getClass().getName()} (end)  #
###############################
"""
    }
}
